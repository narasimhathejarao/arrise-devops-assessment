# DevOps Assignment Answers

## Task 1 — Lifecycle Rule Protection
We enabled `prevent_destroy = true` on `db-primary-01`.
- **Which Instance**: `db-primary-01`
- **Why**: Production database nodes store persistent state and data. Destroying a database instance causes immediate data loss and downtime. Setting `prevent_destroy = true` ensures Terraform blocks accidental execution of `terraform destroy` or key structural replacements.

---

## Task 2 — Remote State & Locking

### Concurrent Execution with Local State
If two people run `terraform apply` simultaneously using local state (`terraform.tfstate`):
1. **Race Conditions & Corruption**: Both executions read the state simultaneously and attempt to create or modify AWS resources in parallel.
2. **State Overwrites**: Whichever execution completes last overwrites `terraform.tfstate`, causing untracked/orphaned resources.

### Prevention via S3 + DynamoDB
1. **S3 Backend**: Acts as a centralized single source of truth for the state file across team members.
2. **DynamoDB Locking**: When a developer runs `apply`, Terraform writes a Lock ID item to DynamoDB. Concurrent runs detect the active lock and exit immediately with `ConditionalCheckFailedException`, preventing parallel modifications.

---

## Task 3 — Multi-Account IAM Answers

### 1. Direct Access Keys vs Production Best Practice
**Would I give `engine` and `ci` access keys in production?**
**No.** Long-lived static access keys present significant security risks if leaked.

**Production Alternatives:**
- **For `ci`**: Use **OpenID Connect (OIDC)** identity federation (e.g., GitHub Actions / GitLab OIDC) to assume short-lived IAM roles dynamically without long-lived credentials.
- **For `engine`**: Use **AWS IAM Identity Center (AWS SSO)** integrated with an enterprise IdP (Okta, Entra ID) using short-lived CLI sessions via `aws sso login`.

### 2. Account Root vs Specific Role Trust Policy
- **Trusting Account A Root (`000000000000:root`)**: Delegates trust entirely to Account A's admin. *Any* identity inside Account A granted `sts:AssumeRole` could assume `roleC`.
- **Trusting `000000000000:role/roleB` directly**: Enforces strict explicit authorization. Only `roleB` is permitted by Account B to assume `roleC`, preserving security boundaries.

---

## Task 4 — Least-Privilege IAM Policy Exclusions

### What was deliberately left out and why?
1. **`Resource: "*"`**: All write actions are scoped strictly to specific target resource ARNs (ECR repository, ECS service/task definitions, S3 bucket).
2. **Broad Admin/Destructive Actions**: Omitted destructive calls (`ecr:DeleteRepository`, `ecs:DeleteService`, `s3:DeleteObject`, `iam:*`).
3. **`s3:PutObject` / `s3:DeleteObject`**: Restricted to read-only access (`s3:GetObject`, `s3:ListBucket`) as required.
4. **Scoped `iam:PassRole`**: Scoped strictly to specific task execution roles with `iam:PassedToService: ecs.amazonaws.com`.

---

## Task 5 — Bug Analysis & Fixes

### Issue 1: Wrong Principal Type in Trust Policy
- **Error**: `identifiers = ["arn:aws:iam::000000000000:user/roleB"]`
- **Reason**: `roleB` is an IAM Role, not an IAM User (`user/roleB`).
- **Fix**: Corrected identifier to `arn:aws:iam::000000000000:role/roleB`.

### Issue 2: Overly Permissive S3 Policy
- **Error**: `Action = "s3:*"` with `Resource = "*"`
- **Reason**: Task 3 requires access scoped strictly to a single named S3 bucket, not all AWS S3 resources.
- **Fix**: Scoped `Resource` to `["arn:aws:s3:::my-named-bucket", "arn:aws:s3:::my-named-bucket/*"]`.