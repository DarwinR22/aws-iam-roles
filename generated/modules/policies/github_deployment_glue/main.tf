# Auto-generated policy module: github_deployment_glue

resource "aws_iam_policy" "github_deployment_glue" {
  name        = "${var.environment}-github-deployment-glue"
  description = "Policy for github-deployment-glue"
  path        = "/"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = []
  })

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-glue"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_glue.yaml"
    }
  )
}
