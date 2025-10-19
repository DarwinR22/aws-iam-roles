# Auto-generated policy module: github_deployment_cloudformation

resource "aws_iam_policy" "github_deployment_cloudformation" {
  name        = "${var.environment}-github-deployment-cloudformation"
  description = "Policy for github-deployment-cloudformation"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name                = "${var.environment}-github-deployment-cloudformation"
      PolicyType         = "Custom"
      Scope              = "Service"
      GeneratedFrom      = "github_deployment_cloudformation.yaml"
    }
  )
}
