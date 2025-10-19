# Auto-generated policy module: github_deployment_compute

resource "aws_iam_policy" "github_deployment_compute" {
  name        = "${var.environment}-github-deployment-compute"
  description = "Policy for github-deployment-compute"
  path        = "/"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-compute"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_compute.yaml"
    }
  )
}
