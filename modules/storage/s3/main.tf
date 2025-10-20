# ==============================================================================
# STORAGE MODULE: S3 ENHANCED
# Propósito: Buckets S3 con versionado, lifecycle, encriptación, replicación
# Compliance: ISO 27001 A.12.3.1, A.18.1.3 | NIST CSF PR.DS-1, PR.DS-6
# ==============================================================================

# ------------------------------------------------------------------------------
# S3 BUCKET - PRIMARY
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "primary" {
  bucket = var.bucket_name
  
  tags = merge(
    var.common_tags,
    {
      Name        = var.bucket_name
      Layer       = "Storage"
      Module      = "S3"
      Compliance  = "ISO27001-A.12.3.1+A.18.1.3"
      DataClass   = var.data_classification
    }
  )
  
  lifecycle {
    prevent_destroy = true
  }
}

# ------------------------------------------------------------------------------
# S3 VERSIONING - IMMUTABILITY & RECOVERY
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_versioning" "primary" {
  bucket = aws_s3_bucket.primary.id
  
  versioning_configuration {
    status     = var.enable_versioning ? "Enabled" : "Suspended"
    mfa_delete = var.enable_mfa_delete ? "Enabled" : "Disabled"
  }
}

# ------------------------------------------------------------------------------
# S3 ENCRYPTION - KMS
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != null ? true : false
  }
}

# ------------------------------------------------------------------------------
# S3 PUBLIC ACCESS BLOCK - SECURITY
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "primary" {
  bucket = aws_s3_bucket.primary.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# S3 LIFECYCLE POLICIES - COST OPTIMIZATION
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "primary" {
  count  = var.enable_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.primary.id
  
  # Transición a IA después de 30 días
  rule {
    id     = "transition-to-ia"
    status = "Enabled"
    
    transition {
      days          = var.lifecycle_ia_days
      storage_class = "STANDARD_IA"
    }
    
    filter {
      prefix = var.lifecycle_prefix
    }
  }
  
  # Transición a Glacier después de 90 días
  rule {
    id     = "transition-to-glacier"
    status = "Enabled"
    
    transition {
      days          = var.lifecycle_glacier_days
      storage_class = "GLACIER"
    }
    
    filter {
      prefix = var.lifecycle_prefix
    }
  }
  
  # Expiración de versiones antiguas
  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    
    noncurrent_version_expiration {
      noncurrent_days = var.version_expiration_days
    }
    
    filter {
      prefix = ""
    }
  }
  
  # Limpieza de uploads incompletos
  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    
    filter {
      prefix = ""
    }
  }
}

# ------------------------------------------------------------------------------
# S3 LOGGING - AUDIT
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_logging" "primary" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.primary.id
  
  target_bucket = var.logging_bucket_name != null ? var.logging_bucket_name : aws_s3_bucket.primary.id
  target_prefix = "access-logs/${var.bucket_name}/"
}

# ------------------------------------------------------------------------------
# S3 OBJECT LOCK - IMMUTABILITY (WORM)
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_object_lock_configuration" "primary" {
  count  = var.enable_object_lock ? 1 : 0
  bucket = aws_s3_bucket.primary.id
  
  rule {
    default_retention {
      mode = "GOVERNANCE" # GOVERNANCE permite eliminación con permisos especiales
      days = var.object_lock_retention_days
    }
  }
}

# ------------------------------------------------------------------------------
# S3 REPLICATION - DR & HA (OPCIONAL)
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_replication_configuration" "primary" {
  count  = var.enable_replication && var.replication_bucket_arn != null ? 1 : 0
  bucket = aws_s3_bucket.primary.id
  role   = var.replication_role_arn
  
  rule {
    id     = "replicate-all"
    status = "Enabled"
    
    filter {
      prefix = ""
    }
    
    destination {
      bucket        = var.replication_bucket_arn
      storage_class = "STANDARD_IA"
      
      # Replicar también el cifrado
      encryption_configuration {
        replica_kms_key_id = var.replication_kms_key_arn
      }
    }
    
    # Replicar también versiones eliminadas
    delete_marker_replication {
      status = "Enabled"
    }
  }
  
  depends_on = [aws_s3_bucket_versioning.primary]
}

# ------------------------------------------------------------------------------
# S3 BUCKET POLICY - SECURITY
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "primary" {
  count  = var.bucket_policy_json != null ? 1 : 0
  bucket = aws_s3_bucket.primary.id
  policy = var.bucket_policy_json
}

# ------------------------------------------------------------------------------
# S3 INTELLIGENT TIERING - AUTO COST OPTIMIZATION
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_intelligent_tiering_configuration" "primary" {
  count  = var.enable_intelligent_tiering ? 1 : 0
  bucket = aws_s3_bucket.primary.id
  name   = "entire-bucket"
  
  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }
  
  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
}

# ------------------------------------------------------------------------------
# CLOUDWATCH METRICS - MONITORING
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_metric" "primary" {
  count  = var.enable_metrics ? 1 : 0
  bucket = aws_s3_bucket.primary.id
  name   = "EntireBucket"
}

# ------------------------------------------------------------------------------
# S3 INVENTORY - AUDIT & REPORTING
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_inventory" "primary" {
  count  = var.enable_inventory ? 1 : 0
  bucket = aws_s3_bucket.primary.id
  name   = "entire-bucket-inventory"
  
  included_object_versions = "All"
  
  schedule {
    frequency = "Daily"
  }
  
  destination {
    bucket {
      format     = "CSV"
      bucket_arn = aws_s3_bucket.primary.arn
      prefix     = "inventory/"
    }
  }
  
  optional_fields = [
    "Size",
    "LastModifiedDate",
    "StorageClass",
    "ETag",
    "IsMultipartUploaded",
    "ReplicationStatus",
    "EncryptionStatus"
  ]
}
