# Auto-generated policy module: github_deployment_tfstate

resource "aws_iam_policy" "github_deployment_tfstate" {
  name        = "${var.environment}-github-deployment-tfstate"
  description = "Policy for github-deployment-tfstate"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name                = "${var.environment}-github-deployment-tfstate"
      PolicyType         = "Custom"
      Scope              = "Service"
      GeneratedFrom      = "github_deployment_tfstate.yaml"
    }
  )
}
