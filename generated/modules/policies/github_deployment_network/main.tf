# Auto-generated policy module: github_deployment_network

resource "aws_iam_policy" "github_deployment_network" {
  name        = "${var.environment}-github-deployment-network"
  description = "Policy for github-deployment-network"
  path        = "/"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-network"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_network.yaml"
    }
  )
}
