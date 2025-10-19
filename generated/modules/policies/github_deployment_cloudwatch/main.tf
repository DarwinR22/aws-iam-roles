# Auto-generated policy module: github_deployment_cloudwatch

resource "aws_iam_policy" "github_deployment_cloudwatch" {
  name        = "${var.environment}-github-deployment-cloudwatch"
  description = "Policy for github-deployment-cloudwatch"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name                = "${var.environment}-github-deployment-cloudwatch"
      PolicyType         = "Custom"
      Scope              = "Service"
      GeneratedFrom      = "github_deployment_cloudwatch.yaml"
    }
  )
}
