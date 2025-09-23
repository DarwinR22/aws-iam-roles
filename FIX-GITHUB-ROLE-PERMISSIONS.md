# 🚨 FIX: GitHub Actions Role Permissions Update Required

## ❌ **Error Encountered**
```
Error: User: arn:aws:sts::393209814297:assumed-role/github-actions-iam-deployment-role/GitHubActions-MCI-IAM-Deploy 
is not authorized to perform: iam:DeletePolicyVersion on resource: policy arn:aws:iam::393209814297:policy/MCI-Deployment-TerraformCore
```

## 🔧 **Root Cause**
The GitHub Actions role is missing some IAM permissions needed for policy version management.

## ✅ **Solution Steps**

### 1. **Apply Updated Permissions (AWS Console)**
1. Go to AWS Console → IAM → Roles
2. Find role: `github-actions-iam-deployment-role`
3. Go to Permissions tab
4. Find policy: `GitHubActionsIAMDeploymentPolicy` 
5. Click Edit → Replace with content from `aws-setup/github-actions-role-policy.json`

### 2. **Apply Updated Permissions (AWS CLI)**
```bash
# Navigate to project root
cd /path/to/mci-aws-iam

# Update the role policy
aws iam put-role-policy \
  --role-name github-actions-iam-deployment-role \
  --policy-name GitHubActionsIAMDeploymentPolicy \
  --policy-document file://aws-setup/github-actions-role-policy.json
```

### 3. **Apply Updated Permissions (PowerShell)**
```powershell
# Navigate to project root
cd "D:\2025\repos\MCI\mci-aws-iam"

# Update the role policy
aws iam put-role-policy `
  --role-name github-actions-iam-deployment-role `
  --policy-name GitHubActionsIAMDeploymentPolicy `
  --policy-document file://aws-setup/github-actions-role-policy.json
```

## 📋 **New Permissions Added**
- `iam:GetPolicyVersion` - Read specific policy versions
- `iam:SetDefaultPolicyVersion` - Manage policy version defaults  
- `iam:TagPolicy` + `iam:UntagPolicy` - Policy tagging management
- `iam:ListPolicyTags` - List policy tags

## 🔄 **After Applying**
1. Re-run the failed GitHub Actions workflow
2. The `iam:DeletePolicyVersion` error should be resolved
3. Policy updates will work correctly

## 🛡️ **Security Note**
These permissions are necessary for Terraform to manage IAM policy versions correctly during infrastructure updates. All permissions are scoped appropriately for deployment automation.

## ⚡ **Quick Fix Command**
```bash
# Run this from AWS CloudShell or any environment with AWS CLI configured
curl -s https://raw.githubusercontent.com/ClaroCENAM/mci-aws-iam/dev/aws-setup/github-actions-role-policy.json | \
aws iam put-role-policy \
  --role-name github-actions-iam-deployment-role \
  --policy-name GitHubActionsIAMDeploymentPolicy \
  --policy-document file:///dev/stdin
```