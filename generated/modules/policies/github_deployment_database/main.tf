# Auto-generated policy module: github_deployment_database

resource "aws_iam_policy" "github_deployment_database" {
  name        = "${var.environment}-github-deployment-database"
  description = "Policy for github-deployment-database"
  path        = "/"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-database"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_database.yaml"
    }
  )
}
