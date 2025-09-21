# docs/legacy-cleanup.md
# Legacy Component Cleanup Guide

**Safe removal of legacy files and migration to Enterprise ABAC Catalog**

## Overview

This document provides the step-by-step process to safely remove legacy components after successful migration to the Enterprise ABAC architecture.

## Legacy Components to Remove

### 1. Legacy Role Definitions

#### Files for Removal
```
gerencias/
└── MCI/
    └── BI/
        └── roles/
            └── rol-bi-analytics-dev-processor.json ❌ REMOVE
```

#### Migration Status
- ✅ **Migrated to**: `catalog/roles.yaml` → `bi-analytics-dev-processor`
- ✅ **Functionality**: Replaced with ABAC-enabled catalog definition
- ✅ **Testing**: Validated in development environment

### 2. Legacy Policy Files

#### Individual Policy Files (Remove After Migration)
```
politicas/
├── MCI-DynamoDB-ReadOnly.json ❌ REMOVE → catalog + policy_lib/dynamodb/
├── MCI-DynamoDB-Table-ReadOnly.json ❌ REMOVE → policy_lib/dynamodb/tag_based_read.tf
├── MCI-DynamoDB-Table-Write.json ❌ REMOVE → policy_lib/dynamodb/tag_based_write.tf
├── MCI-DynamoDB-TagBased-ReadOnly.json ✅ KEEP (already ABAC)
├── MCI-DynamoDB-TagBased-Write.json ✅ KEEP (already ABAC)
├── MCI-DynamoDB-Write.json ❌ REMOVE → policy_lib/dynamodb/
├── MCI-Lambda-Invoke.json ❌ REMOVE → policy_lib/lambda/tag_based_invoke.tf
├── MCI-S3-Path-ReadOnly.json ❌ REMOVE → policy_lib/s3/tag_based_read.tf
├── MCI-S3-Path-Write.json ❌ REMOVE → policy_lib/s3/tag_based_write.tf
├── MCI-S3-ReadOnly.json ❌ REMOVE → policy_lib/s3/
├── MCI-S3-TagBased-ReadOnly.json ✅ KEEP (already ABAC)
├── MCI-S3-TagBased-Write.json ✅ KEEP (already ABAC)
└── MCI-S3-Write.json ❌ REMOVE → policy_lib/s3/
```

#### Subdirectory Policy Files (Remove After Migration)
```
politicas/
├── dynamodb/
│   ├── MCI-DynamoDB-ReadOnly.json ❌ REMOVE → policy_lib/dynamodb/tag_based_read.tf
│   └── MCI-DynamoDB-Write.json ❌ REMOVE → policy_lib/dynamodb/tag_based_write.tf
├── lambda/
│   └── MCI-Lambda-Invoke.json ❌ REMOVE → policy_lib/lambda/tag_based_invoke.tf
├── s3/
│   ├── MCI-S3-ReadOnly.json ❌ REMOVE → policy_lib/s3/tag_based_read.tf
│   └── MCI-S3-Write.json ❌ REMOVE → policy_lib/s3/tag_based_write.tf
└── sqs/
    ├── MCI-SQS-Consume.json ❌ REMOVE → policy_lib/sqs/tag_based_consume.tf
    └── MCI-SQS-Produce.json ❌ REMOVE → policy_lib/sqs/tag_based_produce.tf
```

### 3. Legacy Scripts (Evaluate for Update or Removal)

#### Python Scripts for Role Management
```
scripts/
├── create_role_enterprise.py ✅ KEEP (used with new catalog)
├── create_role.py ❌ REMOVE → replaced by catalog + terraform
├── edit_role_enterprise.py ✅ KEEP (used with new catalog)
├── edit_role.py ❌ REMOVE → replaced by catalog + terraform
├── migrate_to_enterprise.py ✅ KEEP (migration utility)
├── setup-hooks.sh ✅ KEEP (git hooks)
├── tag_examples.json ❌ REMOVE → examples in docs/
└── validate-user-push.sh ✅ KEEP (git validation)
```

## Cleanup Process

### Phase 1: Verification (Before Cleanup)

#### 1.1 Validate New Architecture is Working
```bash
# Test all new roles and policies
cd environments/dev
terraform plan  # Should show no changes
terraform validate  # Should pass all validations

# Run guardrails
conftest verify --policy ../../guardrails/conftest/ .
checkov -d . --config-file ../../guardrails/checkov/.checkov.yaml
```

#### 1.2 Verify No Dependencies on Legacy Files
```bash
# Search for references to legacy files
grep -r "gerencias/" . --exclude-dir=.git
grep -r "MCI-DynamoDB-ReadOnly.json" . --exclude-dir=.git
grep -r "create_role.py" . --exclude-dir=.git
```

#### 1.3 Backup Legacy Components
```bash
# Create backup branch
git checkout -b backup/legacy-components-$(date +%Y%m%d)
git add .
git commit -m "Backup: Legacy components before cleanup"
git push origin backup/legacy-components-$(date +%Y%m%d)
```

### Phase 2: Safe Removal

#### 2.1 Remove Legacy Role Definitions
```bash
# Remove legacy role JSON files
rm -rf gerencias/
git add gerencias/
git commit -m "Remove legacy role definitions - migrated to catalog/roles.yaml"
```

#### 2.2 Remove Legacy Policy Files
```bash
# Remove duplicate/legacy policy files
rm politicas/MCI-DynamoDB-ReadOnly.json
rm politicas/MCI-DynamoDB-Table-ReadOnly.json
rm politicas/MCI-DynamoDB-Table-Write.json
rm politicas/MCI-DynamoDB-Write.json
rm politicas/MCI-Lambda-Invoke.json
rm politicas/MCI-S3-Path-ReadOnly.json
rm politicas/MCI-S3-Path-Write.json
rm politicas/MCI-S3-ReadOnly.json
rm politicas/MCI-S3-Write.json

# Remove subdirectory duplicates
rm -rf politicas/dynamodb/
rm -rf politicas/lambda/
rm -rf politicas/s3/
rm -rf politicas/sqs/

git add politicas/
git commit -m "Remove legacy policy files - migrated to policy_lib with ABAC"
```

#### 2.3 Remove Legacy Scripts
```bash
# Remove outdated scripts
rm scripts/create_role.py
rm scripts/edit_role.py
rm scripts/tag_examples.json

git add scripts/
git commit -m "Remove legacy scripts - replaced by enterprise catalog workflow"
```

### Phase 3: Update References

#### 3.1 Update Documentation
```bash
# Update any references in documentation
grep -r "gerencias/" docs/ README.md
# Manually update found references to point to new catalog
```

#### 3.2 Update CI/CD if Needed
```bash
# Check CI files for legacy references
grep -r "politicas/" .github/ ci/
# Update any found references
```

#### 3.3 Update Makefile if Present
```bash
# Check Makefile for legacy references
grep -E "(gerencias|create_role\.py)" Makefile
# Update any found references
```

### Phase 4: Final Validation

#### 4.1 Run Full Test Suite
```bash
# Validate everything still works
make test || terraform validate
conftest verify --policy guardrails/conftest/ environments/dev/
checkov -d environments/dev/ --config-file guardrails/checkov/.checkov.yaml
```

#### 4.2 Check for Broken References
```bash
# Search for any remaining references to removed files
grep -r "gerencias" . --exclude-dir=.git || echo "✅ No references found"
grep -r "MCI-DynamoDB-ReadOnly.json" . --exclude-dir=.git || echo "✅ No references found"
grep -r "create_role.py" . --exclude-dir=.git || echo "✅ No references found"
```

#### 4.3 Test New Workflow
```bash
# Test creating a new role via catalog
# Edit catalog/roles.yaml, add new role, then:
cd environments/dev
terraform plan  # Should show the new role
```

## Post-Cleanup Structure

### New Clean Structure
```
mci-aws-iam/
├── modules/          # Enterprise modules
├── policy_lib/       # ABAC building blocks  
├── catalog/          # Single source of truth
├── guardrails/       # Security validation
├── ci/              # Enterprise CI/CD
├── environments/     # Environment configs
├── docs/            # Enterprise documentation
├── scripts/         # Enterprise utilities only
├── politicas/       # Only ABAC policies kept
│   ├── MCI-DynamoDB-TagBased-ReadOnly.json ✅
│   ├── MCI-DynamoDB-TagBased-Write.json ✅
│   ├── MCI-S3-TagBased-ReadOnly.json ✅
│   └── MCI-S3-TagBased-Write.json ✅
└── README.md        # Enterprise documentation
```

### Removed Legacy Structure
```
❌ gerencias/                    # Legacy role definitions
❌ politicas/dynamodb/           # Duplicate policy files
❌ politicas/lambda/             # Duplicate policy files
❌ politicas/s3/                 # Duplicate policy files  
❌ politicas/sqs/                # Duplicate policy files
❌ politicas/MCI-*-ReadOnly.json # Non-ABAC policies
❌ scripts/create_role.py        # Legacy role creation
❌ scripts/edit_role.py          # Legacy role editing
❌ scripts/tag_examples.json     # Replaced by docs
```

## Rollback Plan

### If Issues Found After Cleanup

#### Immediate Rollback
```bash
# Restore from backup branch
git checkout backup/legacy-components-$(date +%Y%m%d)
git checkout -b fix/restore-legacy-components
git cherry-pick <working-commit>  # Pick only the fixes needed
```

#### Selective Restore
```bash
# Restore specific files if needed
git checkout backup/legacy-components-$(date +%Y%m%d) -- gerencias/
git checkout backup/legacy-components-$(date +%Y%m%d) -- politicas/dynamodb/
git add .
git commit -m "Selective restore of legacy components"
```

## Success Criteria

### Cleanup Completion Checklist
- [ ] ✅ All new roles working via catalog
- [ ] ✅ All policies using ABAC patterns
- [ ] ✅ No references to removed files
- [ ] ✅ Full test suite passing
- [ ] ✅ Documentation updated
- [ ] ✅ Backup created and verified
- [ ] ✅ Team notified of changes

### Quality Gates
- [ ] ✅ Terraform validate passes
- [ ] ✅ Conftest rules pass
- [ ] ✅ Checkov scans pass
- [ ] ✅ No broken links in documentation
- [ ] ✅ All CI/CD pipelines working

### Monitoring
- [ ] ✅ CloudTrail events normal
- [ ] ✅ No application errors
- [ ] ✅ Performance unchanged
- [ ] ✅ Security compliance maintained

---

**Cleanup Lead**: @devops-team  
**Security Review**: @seguridad-cloud  
**Approval Required**: ✅ Before removing any files  
**Rollback Time**: < 5 minutes with backup branch  
**Next Review**: After 30 days post-cleanup