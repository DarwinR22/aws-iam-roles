bucket         = "s3-data-analytics-dev-tfstate-datalake"
key            = "iam/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "dynamodb-db-dev-terraform-lock"
encrypt        = true