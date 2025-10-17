# Import existing IAM role into Terraform state
# Run from root directory

Write-Host "Importando rol IAM github-actions-iam-deployment-role..." -ForegroundColor Cyan

$env:AWS_PROFILE = "darkh"

Set-Location -Path "generated"

Write-Host "`nImportando github-actions-iam-deployment-role..."
terraform import "aws_iam_role.github_actions_iam_deployment_role" "github-actions-iam-deployment-role"

Set-Location -Path ".."

Write-Host "`nCompletado!" -ForegroundColor Green
