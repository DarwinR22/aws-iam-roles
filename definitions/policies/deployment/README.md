# Deployment IAM Policies - Modular Structure

This directory contains the YAML definitions for deployment permissions (GitHub Actions, CI/CD pipelines), organized as business policies for deployment operations.

## 📁 **File Structure**

```
definitions/policies/deployment/
├── github-deployment-role.yaml    # Main role definition with OIDC trust policy
├── base-permissions.yaml          # Fundamental AWS permissions (STS)
├── terraform-backend.yaml         # S3, DynamoDB, KMS for Terraform state
├── iam-management.yaml            # Complete IAM management permissions
└── README.md                      # This documentation
```

## 🎯 **Architecture Overview**

### **Modular Design Benefits:**
- ✅ **Separation of Concerns:** Each file has a specific responsibility
- ✅ **Reusability:** Policies can be reused across different roles
- ✅ **Maintainability:** Changes are isolated and easy to track
- ✅ **Security:** Granular permissions for better audit trails
- ✅ **Compliance:** ABAC conditions enforce organizational policies

### **Policy Modules:**

#### 1. **base-permissions.yaml**
- **Purpose:** Fundamental AWS permissions
- **Services:** STS (identity verification)
- **Risk Level:** Low
- **Dependencies:** None

#### 2. **terraform-backend.yaml** 
- **Purpose:** Terraform state management
- **Services:** S3, DynamoDB, KMS
- **Risk Level:** Medium
- **Dependencies:** Base permissions

#### 3. **iam-management.yaml**
- **Purpose:** IAM resource management
- **Services:** IAM (roles, policies, attachments)
- **Risk Level:** High
- **Dependencies:** Base permissions, Terraform backend

#### 4. **github-deployment-role.yaml**
- **Purpose:** Main role configuration
- **Components:** OIDC trust policy + policy module references
- **Risk Level:** High (combines all permissions)
- **Dependencies:** All above policy modules

## 🔐 **Security Features**

### **ABAC (Attribute-Based Access Control)**
All policies include ABAC conditions for:
- **Gerencia:** MCI organizational boundary
- **Ambiente:** Environment isolation (dev/qa/prod)
- **Layer:** DevOps operations restriction

### **OIDC Configuration**
- **Provider:** GitHub Actions OIDC
- **Repository Scope:** ClaroCENAM/* organization
- **Session Duration:** 1 hour maximum
- **Audience:** sts.amazonaws.com

### **Resource Constraints**
- **IAM Resources:** Limited to organizational prefixes
- **S3 Access:** Restricted to Terraform state buckets
- **DynamoDB:** Limited to state locking tables
- **KMS:** Contextual access via S3/DynamoDB services

## 🚀 **Usage Workflow**

### **Development Process:**
1. Edit YAML files for policy changes
2. Generator processes YAML → Terraform
3. Pull request review for security validation
4. Automated tests validate policy syntax
5. Apply changes via GitHub Actions

### **Adding New Permissions:**
1. Create new policy module YAML file
2. Reference in `github-deployment-role.yaml`
3. Test in development environment
4. Review and approve changes
5. Deploy to production

## 📋 **Variables and Customization**

### **Environment Variables:**
- `environment`: Target environment (dev/qa/prod)
- `account_id`: AWS account identifier
- `aws_region`: AWS region for resources

### **Organizational Variables:**
- `role_prefix`: Prefix for manageable IAM roles
- `policy_prefix`: Prefix for manageable IAM policies
- `s3_bucket_name`: Terraform state bucket
- `dynamodb_table_name`: State locking table

## 🔍 **Monitoring and Compliance**

### **Logging:**
- All IAM operations logged via CloudTrail
- CloudWatch metrics for policy usage
- GitHub Actions logs for deployment tracking

### **Compliance Checks:**
- Policy syntax validation
- ABAC condition verification
- OIDC configuration validation
- Resource prefix compliance

## 🛠️ **Maintenance**

### **Regular Tasks:**
- Review and update ABAC conditions
- Validate OIDC provider configuration
- Audit created IAM resources
- Update documentation for policy changes

### **Security Reviews:**
- Monthly access review of created resources
- Quarterly policy effectiveness assessment
- Annual security architecture review
- Incident-based policy adjustments

## 📞 **Support**

- **Technical Owner:** DevOps Team
- **Security Contact:** darwin.lopez@claro.com.gt
- **Documentation:** This README and inline YAML comments
- **Issue Tracking:** GitHub Issues in repository