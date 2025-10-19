# Auto-generated policy module: github_deployment_application

resource "aws_iam_policy" "github_deployment_application" {
  name        = "${var.environment}-github-deployment-application"
  description = "Policy for github-deployment-application"
  path        = "/"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-application"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_application.yaml"
    }
  )
}
