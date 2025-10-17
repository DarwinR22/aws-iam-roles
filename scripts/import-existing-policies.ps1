# Import existing IAM policies into Terraform state
# Run from root directory

Write-Host "Importando politicas IAM existentes..." -ForegroundColor Cyan

$env:AWS_PROFILE = "darkh"
$ACCOUNT_ID = "393209814297"

Set-Location -Path "generated"

Write-Host "`nImportando github-deployment-cloudformation..."
terraform import "module.github_deployment_cloudformation.aws_iam_policy.main" "arn:aws:iam::${ACCOUNT_ID}:policy/github-deployment-cloudformation"

Write-Host "`nImportando github-deployment-cloudwatch..."
terraform import "module.github_deployment_cloudwatch.aws_iam_policy.main" "arn:aws:iam::${ACCOUNT_ID}:policy/github-deployment-cloudwatch"

Write-Host "`nImportando github-deployment-dynamodb..."
terraform import "module.github_deployment_dynamodb.aws_iam_policy.main" "arn:aws:iam::${ACCOUNT_ID}:policy/github-deployment-dynamodb"

Write-Host "`nImportando github-deployment-eventbridge..."
terraform import "module.github_deployment_eventbridge.aws_iam_policy.main" "arn:aws:iam::${ACCOUNT_ID}:policy/github-deployment-eventbridge"

Write-Host "`nImportando github-deployment-glue..."
terraform import "module.github_deployment_glue.aws_iam_policy.main" "arn:aws:iam::${ACCOUNT_ID}:policy/github-deployment-glue"

Write-Host "`nImportando github-deployment-iam..."
terraform import "module.github_deployment_iam.aws_iam_policy.main" "arn:aws:iam::${ACCOUNT_ID}:policy/github-deployment-iam"

Write-Host "`nImportando github-deployment-lambda..."
terraform import "module.github_deployment_lambda.aws_iam_policy.main" "arn:aws:iam::${ACCOUNT_ID}:policy/github-deployment-lambda"

Write-Host "`nImportando github-deployment-s3..."
terraform import "module.github_deployment_s3.aws_iam_policy.main" "arn:aws:iam::${ACCOUNT_ID}:policy/github-deployment-s3"

Write-Host "`nImportando github-deployment-tfstate..."
terraform import "module.github_deployment_tfstate.aws_iam_policy.main" "arn:aws:iam::${ACCOUNT_ID}:policy/github-deployment-tfstate"

Set-Location -Path ".."

Write-Host "`nCompletado!" -ForegroundColor Green
