# Auto-generated policy module: github_deployment_sts

resource "aws_iam_policy" "github_deployment_sts" {
  name        = "${var.environment}-github-deployment-sts"
  description = "Policy for github-deployment-sts"
  path        = "/"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-sts"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_sts.yaml"
    }
  )
}
