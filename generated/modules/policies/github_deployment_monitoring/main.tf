# Auto-generated policy module: github_deployment_monitoring

resource "aws_iam_policy" "github_deployment_monitoring" {
  name        = "${var.environment}-github-deployment-monitoring"
  description = "Policy for github-deployment-monitoring"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name                = "${var.environment}-github-deployment-monitoring"
      PolicyType         = "Custom"
      Scope              = "Service"
      GeneratedFrom      = "github_deployment_monitoring.yaml"
    }
  )
}
