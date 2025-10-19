# Auto-generated policy module: github_deployment_storage

resource "aws_iam_policy" "github_deployment_storage" {
  name        = "${var.environment}-github-deployment-storage"
  description = "Policy for github-deployment-storage"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name                = "${var.environment}-github-deployment-storage"
      PolicyType         = "Custom"
      Scope              = "Service"
      GeneratedFrom      = "github_deployment_storage.yaml"
    }
  )
}
