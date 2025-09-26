terraform {
  backend "s3" {
    bucket         = "s3-data-analytics-dev-tfstate-datalake"
    key            = "iam-management/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mci-terraform-locks"
    encrypt        = true
  }
}
