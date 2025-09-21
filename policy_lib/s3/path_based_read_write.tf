# policy_lib/s3/path_based_read_write.tf
# ================================================
# S3 Path-Based Read/Write Policy Building Block
# Para acceso específico a rutas de S3
# ================================================

locals {
  s3_path_based_read_write_policy = {
    Version = "2012-10-17"
    Statement = [
      # Permisos para listar bucket (necesario para navegación)
      {
        Sid    = "S3ListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = var.s3_bucket_arn
        Condition = {
          StringLike = {
            "s3:prefix" = "${var.s3_path_prefix}*"
          }
        }
      },
      # Permisos de lectura en la ruta específica
      {
        Sid    = "S3ReadObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAttributes"
        ]
        Resource = "${var.s3_bucket_arn}/${var.s3_path_prefix}*"
      },
      # Permisos de escritura en la ruta específica
      {
        Sid    = "S3WriteObjects"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject"
        ]
        Resource = "${var.s3_bucket_arn}/${var.s3_path_prefix}*"
      }
    ]
  }
}

# Variables para personalizar el building block
variable "s3_bucket_arn" {
  description = "ARN del bucket S3"
  type        = string
  default     = ""
}

variable "s3_path_prefix" {
  description = "Prefijo de la ruta en S3 (sin / al final)"
  type        = string
  default     = ""
}

# Output del policy JSON
output "s3_path_based_read_write_policy_json" {
  description = "Policy JSON para acceso específico a ruta S3"
  value       = jsonencode(local.s3_path_based_read_write_policy)
}