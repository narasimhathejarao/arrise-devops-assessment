# DevOps Technical Assessment - Arrise Solution

This repository contains the completed Terraform and IAM security configuration files for the Arrise DevOps Technical Assessment. The implementation includes multi-instance EC2 provisioning, remote state management with DynamoDB locking, cross-account IAM role structures, least-privilege CI/CD policies, and code fix analysis.

## Repository Structure

```
.
├── backend.tf          # Task 2: Remote S3 backend configuration with DynamoDB state locking
├── iam.tf              # Task 3 & 5: Multi-account IAM structure and fixed cross-account trust policies
├── main.tf             # Task 1: Multi-instance EC2 module driven by for_each with custom EBS volumes
├── outputs.tf          # Task 1: Map outputs for instance IDs and private IP addresses
├── policy_ci.json      # Task 4: Standalone JSON policy for CI/CD least-privilege access
├── terraform.tfvars    # Task 1: Definition of the 5 required EC2 instance configurations
├── variables.tf        # Task 1: Type-constrained variable definitions
├── NOTES.md            # Written responses for Tasks 1, 2, 3, 4, and 5
└── .gitignore          # Git exclusion rules for local terraform state and binary caches
```

## Tasks Summary

### Task 1: Provision Multiple EC2 Instances with Dynamic Configuration

* **Module Design**: Configured `main.tf` using a single `aws_instance` resource powered by `for_each` over a complex map variable (`var.instances_config`).
* **Dynamic Volumes**: Implemented dynamic `root_block_device` and `ebs_block_device` blocks to handle variable volume types (`gp3`, `io2`) and IOPS conditionally.
* **Protection & Outputs**: Added `prevent_destroy = true` lifecycle guards to critical instances and produced structured map outputs in `outputs.tf`.

### Task 2: Remote State & State Locking Architecture

* **Backend Setup**: Configured S3 remote state storage with DynamoDB table state locking in `backend.tf`.
* **Concurrency Prevention**: Documented the mechanics of state locking and race condition prevention during concurrent deployments in `NOTES.md`.

### Task 3: Multi-Account IAM Design

* **Role & Group Setup**: Formulated IAM trust relationships in `iam.tf` between Account A (`111111111111`) and Account B (`222221111111`) covering Dev and Ops team permissions.
* **Security Best Practices**: Documented security trade-offs (Access Keys vs. OIDC/SSO and Root vs. Specific Role Trust Policies) in `NOTES.md`.

### Task 4: Write a Custom Least-Privilege IAM Policy

* **CI/CD Authorization**: Created `policy_ci.json` enabling image pushes to Amazon ECR, deployment triggering in Amazon ECS, and read-only access to build artifact S3 buckets.
* **Exclusions & Scoping**: Applied exact resource ARNs and documented intentional permission exclusions in `NOTES.md`.

### Task 5: Find and Fix the Bug

* **Bug Fix**: Identified and resolved the malformed principal path in the trust policy and removed over-permissive wildcard resources (`*`) for S3 buckets.
* **Analysis**: Detailed the root cause and resolution in both `iam.tf` and `NOTES.md`.

## Local Validation & Usage

To validate and test this repository locally:

```bash
# Initialize working directory without invoking remote S3 backend
terraform init -backend=false

# Check code formatting against HashiCorp standards
terraform fmt -check

# Validate syntax and reference integrity
terraform validate
```

## Prerequisites

* **Terraform**: v1.0.0+
* **AWS Provider**: ~> 5.0