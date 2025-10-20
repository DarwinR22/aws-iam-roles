# Auto-generated policy module: github_deployment_storage

resource "aws_iam_policy" "github_deployment_storage" {
  name        = "${var.environment}-github-deployment-storage"
  description = "GitHub Actions deployment policy for Storage infrastructure (S3, EFS, EBS, Backup)"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:ListBucket",
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning",
        "s3:GetBucketPolicy",
        "s3:PutBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:GetBucketAcl",
        "s3:PutBucketAcl",
        "s3:GetBucketCors",
        "s3:PutBucketCors",
        "s3:GetBucketLifecycleConfiguration",
        "s3:PutBucketLifecycleConfiguration",
        "s3:GetBucketReplication",
        "s3:PutBucketReplication",
        "s3:GetBucketNotification",
        "s3:PutBucketNotification",
        "s3:GetEncryptionConfiguration",
        "s3:PutEncryptionConfiguration",
        "s3:GetBucketPublicAccessBlock",
        "s3:PutBucketPublicAccessBlock",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObjectVersion",
        "s3:DeleteObjectVersion",
        "s3:RestoreObject"
      ],
      "Sid": "S3BucketManagement",
      "Resource": [
        "arn:aws:s3:::sgsi-*",
        "arn:aws:s3:::sgsi-*/*",
        "arn:aws:s3:::*-sgsi-*",
        "arn:aws:s3:::*-sgsi-*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeVolumes",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:ModifyVolume",
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:DescribeSnapshots",
        "ec2:CopySnapshot",
        "ec2:ModifySnapshotAttribute"
      ],
      "Sid": "EBSVolumeManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateFileSystem",
        "elasticfilesystem:DeleteFileSystem",
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:CreateMountTarget",
        "elasticfilesystem:DeleteMountTarget",
        "elasticfilesystem:DescribeMountTargets",
        "elasticfilesystem:ModifyMountTargetSecurityGroups",
        "elasticfilesystem:CreateAccessPoint",
        "elasticfilesystem:DeleteAccessPoint",
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:PutFileSystemPolicy",
        "elasticfilesystem:DescribeFileSystemPolicy",
        "elasticfilesystem:DeleteFileSystemPolicy"
      ],
      "Sid": "EFSManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "backup:CreateBackupPlan",
        "backup:DeleteBackupPlan",
        "backup:GetBackupPlan",
        "backup:ListBackupPlans",
        "backup:UpdateBackupPlan",
        "backup:CreateBackupSelection",
        "backup:DeleteBackupSelection",
        "backup:GetBackupSelection",
        "backup:ListBackupSelections",
        "backup:CreateBackupVault",
        "backup:DeleteBackupVault",
        "backup:DescribeBackupVault",
        "backup:ListBackupVaults",
        "backup:PutBackupVaultAccessPolicy",
        "backup:DeleteBackupVaultAccessPolicy",
        "backup:GetBackupVaultAccessPolicy",
        "backup:PutBackupVaultNotifications",
        "backup:DeleteBackupVaultNotifications",
        "backup:GetBackupVaultNotifications",
        "backup:PutBackupVaultLockConfiguration",
        "backup:StartBackupJob",
        "backup:StopBackupJob",
        "backup:DescribeBackupJob",
        "backup:ListBackupJobs",
        "backup:StartRestoreJob",
        "backup:DescribeRestoreJob",
        "backup:ListRestoreJobs"
      ],
      "Sid": "BackupManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "fsx:CreateFileSystem",
        "fsx:DeleteFileSystem",
        "fsx:DescribeFileSystems",
        "fsx:CreateBackup",
        "fsx:DeleteBackup",
        "fsx:DescribeBackups",
        "fsx:RestoreVolumeFromSnapshot"
      ],
      "Sid": "FSxManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:CreateKey",
        "kms:DescribeKey",
        "kms:ListKeys",
        "kms:ListAliases",
        "kms:CreateAlias",
        "kms:DeleteAlias",
        "kms:GetKeyPolicy",
        "kms:PutKeyPolicy",
        "kms:EnableKey",
        "kms:DisableKey",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ListResourceTags",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:CreateGrant"
      ],
      "Sid": "KMSForStorage",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "storagegateway:CreateGateway",
        "storagegateway:DeleteGateway",
        "storagegateway:DescribeGatewayInformation",
        "storagegateway:ListGateways",
        "storagegateway:CreateNFSFileShare",
        "storagegateway:DeleteFileShare",
        "storagegateway:DescribeNFSFileShares",
        "storagegateway:UpdateNFSFileShare"
      ],
      "Sid": "StorageGatewayManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dlm:CreateLifecyclePolicy",
        "dlm:DeleteLifecyclePolicy",
        "dlm:GetLifecyclePolicy",
        "dlm:GetLifecyclePolicies",
        "dlm:UpdateLifecyclePolicy"
      ],
      "Sid": "DataLifecycleManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketTagging",
        "s3:PutBucketTagging",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeTags",
        "elasticfilesystem:CreateTags",
        "elasticfilesystem:DeleteTags",
        "elasticfilesystem:DescribeTags"
      ],
      "Sid": "StorageTagging",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-storage"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_storage.yaml"
    }
  )
}
