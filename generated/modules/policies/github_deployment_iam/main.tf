# Auto-generated policy module: github_deployment_iam

resource "aws_iam_policy" "github_deployment_iam" {
  name        = "${var.environment}-github-deployment-iam"
  description = "Policy for github-deployment-iam"
  path        = "/"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-iam"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_iam.yaml"
    }
  )
}
