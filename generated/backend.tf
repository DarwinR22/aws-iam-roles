terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-051963532279"
    key            = "aws-iam-roles/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
