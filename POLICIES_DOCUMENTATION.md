# 📋 IAM Policies Documentation

Auto-generated documentation for all IAM policies.

**Generated:** 2025-09-22 18:09:14 UTC

---

## 📑 Table of Contents

- [MCI-S3-TagBased-ReadOnly](#mcis3tagbasedreadonly)
- [MCI-S3-TagBased-Write](#mcis3tagbasedwrite)
- [MCI-S3-ReadOnly](#mcis3readonly)
- [MCI-S3-Write](#mcis3write)
- [MCI-Deployment-TerraformCore](#mcideploymentterraformcore)
- [MCI-Deployment-S3Analytics](#mcideployments3analytics)
- [MCI-Deployment-CloudFormation](#mcideploymentcloudformation)
- [MCI-Deployment-Lambda](#mcideploymentlambda)
- [MCI-Deployment-Logs](#mcideploymentlogs)

---

## MCI-S3-TagBased-ReadOnly

**Description:** S3 read-only access based on matching resource tags with principal tags

**Type:** managed

**Policy Document:** `s3.s3_tag_based_read`

### 🏷️ **Canonical Tags:**

| Tag | Value |
|-----|-------|
| Ambiente | dev |
| Pais | rg |
| Direccion | ticenam |
| Gerencia | mci |
| Cuenta | 393209814297 |
| Modulo | storageaccess |
| Alcance SOX | no |
| Propietario | darwinlopez |
| Proveedor | inhouse |
| Layer | security |
| Dominio | dataaccess |
| Subdominio | s3 |
| Aplicacion | abacpolicies |
| Name | MCI-S3-TagBased-ReadOnly |
| Soporte | darwin.lopez@claro.com.gt |

### 💡 **Usage Example:**

```hcl
resource "aws_iam_policy" "example" {
  name        = "MCI-S3-TagBased-ReadOnly"
  description = "S3 read-only access based on matching resource tags with principal tags"
  policy      = data.aws_iam_policy_document.policy.json
}
```

---

## MCI-S3-TagBased-Write

**Description:** S3 write access based on matching resource tags with principal tags

**Type:** managed

**Policy Document:** `s3.s3_tag_based_write`

### 🏷️ **Canonical Tags:**

| Tag | Value |
|-----|-------|
| Ambiente | dev |
| Pais | rg |
| Direccion | ticenam |
| Gerencia | mci |
| Cuenta | 393209814297 |
| Modulo | storageaccess |
| Alcance SOX | si |
| Propietario | darwinlopez |
| Proveedor | inhouse |
| Layer | security |
| Dominio | dataaccess |
| Subdominio | s3 |
| Aplicacion | abacpolicies |
| Name | MCI-S3-TagBased-Write |
| Soporte | darwin.lopez@claro.com.gt |

### 💡 **Usage Example:**

```hcl
resource "aws_iam_policy" "example" {
  name        = "MCI-S3-TagBased-Write"
  description = "S3 write access based on matching resource tags with principal tags"
  policy      = data.aws_iam_policy_document.policy.json
}
```

---

## MCI-S3-ReadOnly

**Description:** Basic S3 read-only access for specific bucket patterns

**Type:** managed

**Policy Document:** `s3.s3_read_only`

### 🏷️ **Canonical Tags:**

| Tag | Value |
|-----|-------|
| Ambiente | dev |
| Pais | rg |
| Direccion | ticenam |
| Gerencia | mci |
| Cuenta | 393209814297 |
| Modulo | storageaccess |
| Alcance SOX | no |
| Propietario | darwinlopez |
| Proveedor | inhouse |
| Layer | security |
| Dominio | dataaccess |
| Subdominio | s3 |
| Aplicacion | basicpolicies |
| Name | MCI-S3-ReadOnly |
| Soporte | darwin.lopez@claro.com.gt |

### 💡 **Usage Example:**

```hcl
resource "aws_iam_policy" "example" {
  name        = "MCI-S3-ReadOnly"
  description = "Basic S3 read-only access for specific bucket patterns"
  policy      = data.aws_iam_policy_document.policy.json
}
```

---

## MCI-S3-Write

**Description:** S3 write access for specific bucket patterns

**Type:** managed

**Policy Document:** `s3.s3_write`

### 🏷️ **Canonical Tags:**

| Tag | Value |
|-----|-------|
| Ambiente | dev |
| Pais | rg |
| Direccion | ticenam |
| Gerencia | mci |
| Cuenta | 393209814297 |
| Modulo | storageaccess |
| Alcance SOX | si |
| Propietario | darwinlopez |
| Proveedor | inhouse |
| Layer | security |
| Dominio | dataaccess |
| Subdominio | s3 |
| Aplicacion | basicpolicies |
| Name | MCI-S3-Write |
| Soporte | darwin.lopez@claro.com.gt |

### 💡 **Usage Example:**

```hcl
resource "aws_iam_policy" "example" {
  name        = "MCI-S3-Write"
  description = "S3 write access for specific bucket patterns"
  policy      = data.aws_iam_policy_document.policy.json
}
```

---

## MCI-Deployment-TerraformCore

**Description:** Core Terraform deployment permissions for IAM and Organizations (GitHub Actions only)

**Type:** managed

**Policy Document:** `deployment.terraform_core_deployment`

### 🏷️ **Canonical Tags:**

| Tag | Value |
|-----|-------|
| Ambiente | all |
| Pais | rg |
| Direccion | ticenam |
| Gerencia | mci |
| Cuenta | 393209814297 |
| Modulo | deployment |
| Alcance SOX | si |
| Propietario | darwinlopez |
| Proveedor | inhouse |
| Layer | cicd |
| Dominio | deployment |
| Subdominio | terraform |
| Aplicacion | githubactions |
| Name | MCI-Deployment-TerraformCore |
| Soporte | darwin.lopez@claro.com.gt |

### 💡 **Usage Example:**

```hcl
resource "aws_iam_policy" "example" {
  name        = "MCI-Deployment-TerraformCore"
  description = "Core Terraform deployment permissions for IAM and Organizations (GitHub Actions only)"
  policy      = data.aws_iam_policy_document.policy.json
}
```

---

## MCI-Deployment-S3Analytics

**Description:** S3 Analytics and bucket management deployment permissions (GitHub Actions only)

**Type:** managed

**Policy Document:** `deployment.s3_analytics_deployment`

### 🏷️ **Canonical Tags:**

| Tag | Value |
|-----|-------|
| Ambiente | all |
| Pais | rg |
| Direccion | ticenam |
| Gerencia | mci |
| Cuenta | 393209814297 |
| Modulo | deployment |
| Alcance SOX | si |
| Propietario | darwinlopez |
| Proveedor | inhouse |
| Layer | cicd |
| Dominio | deployment |
| Subdominio | s3 |
| Aplicacion | githubactions |
| Name | MCI-Deployment-S3Analytics |
| Soporte | darwin.lopez@claro.com.gt |

### 💡 **Usage Example:**

```hcl
resource "aws_iam_policy" "example" {
  name        = "MCI-Deployment-S3Analytics"
  description = "S3 Analytics and bucket management deployment permissions (GitHub Actions only)"
  policy      = data.aws_iam_policy_document.policy.json
}
```

---

## MCI-Deployment-CloudFormation

**Description:** CloudFormation deployment permissions (GitHub Actions only)

**Type:** managed

**Policy Document:** `deployment.cloudformation_deployment`

### 🏷️ **Canonical Tags:**

| Tag | Value |
|-----|-------|
| Ambiente | all |
| Pais | rg |
| Direccion | ticenam |
| Gerencia | mci |
| Cuenta | 393209814297 |
| Modulo | deployment |
| Alcance SOX | si |
| Propietario | darwinlopez |
| Proveedor | inhouse |
| Layer | cicd |
| Dominio | deployment |
| Subdominio | cloudformation |
| Aplicacion | githubactions |
| Name | MCI-Deployment-CloudFormation |
| Soporte | darwin.lopez@claro.com.gt |

### 💡 **Usage Example:**

```hcl
resource "aws_iam_policy" "example" {
  name        = "MCI-Deployment-CloudFormation"
  description = "CloudFormation deployment permissions (GitHub Actions only)"
  policy      = data.aws_iam_policy_document.policy.json
}
```

---

## MCI-Deployment-Lambda

**Description:** Lambda deployment permissions with IAM PassRole (GitHub Actions only)

**Type:** managed

**Policy Document:** `deployment.lambda_deployment`

### 🏷️ **Canonical Tags:**

| Tag | Value |
|-----|-------|
| Ambiente | all |
| Pais | rg |
| Direccion | ticenam |
| Gerencia | mci |
| Cuenta | 393209814297 |
| Modulo | deployment |
| Alcance SOX | si |
| Propietario | darwinlopez |
| Proveedor | inhouse |
| Layer | cicd |
| Dominio | deployment |
| Subdominio | lambda |
| Aplicacion | githubactions |
| Name | MCI-Deployment-Lambda |
| Soporte | darwin.lopez@claro.com.gt |

### 💡 **Usage Example:**

```hcl
resource "aws_iam_policy" "example" {
  name        = "MCI-Deployment-Lambda"
  description = "Lambda deployment permissions with IAM PassRole (GitHub Actions only)"
  policy      = data.aws_iam_policy_document.policy.json
}
```

---

## MCI-Deployment-Logs

**Description:** CloudWatch Logs deployment permissions (GitHub Actions only)

**Type:** managed

**Policy Document:** `deployment.logs_deployment`

### 🏷️ **Canonical Tags:**

| Tag | Value |
|-----|-------|
| Ambiente | all |
| Pais | rg |
| Direccion | ticenam |
| Gerencia | mci |
| Cuenta | 393209814297 |
| Modulo | deployment |
| Alcance SOX | si |
| Propietario | darwinlopez |
| Proveedor | inhouse |
| Layer | cicd |
| Dominio | deployment |
| Subdominio | logs |
| Aplicacion | githubactions |
| Name | MCI-Deployment-Logs |
| Soporte | darwin.lopez@claro.com.gt |

### 💡 **Usage Example:**

```hcl
resource "aws_iam_policy" "example" {
  name        = "MCI-Deployment-Logs"
  description = "CloudWatch Logs deployment permissions (GitHub Actions only)"
  policy      = data.aws_iam_policy_document.policy.json
}
```

---

## 📊 Summary

**Total Policies:** 9

**Policies by Type:**
- managed: 9

---

*This documentation is auto-generated from the policies catalog. Do not edit manually - changes will be overwritten.*
