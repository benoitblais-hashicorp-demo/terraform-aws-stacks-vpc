# AGENTS.md — terraform-aws-stacks-vpc

This file provides context and instructions for AI coding agents (Bob, Copilot, etc.) working on this repository.

---

## Project Overview

This repository is a **reusable Terraform Stack component** (Pattern A) that provisions a production-ready, multi-AZ **AWS VPC** using OIDC workload identity authentication.

- **Pattern:** Component-only repo — no deployment configuration lives here
- **Stack runtime:** HCP Terraform (Stacks GA, Terraform CLI >= 1.13.4)
- **Cloud provider:** AWS (`hashicorp/aws ~> 6.0`)
- **Authentication:** AWS OIDC workload identity — no static credentials; HCP Terraform generates an ephemeral JWT exchanged via `assume_role_with_web_identity`
- **Consumed by:** A separate Stack orchestration repository that provides `deployments.tfdeploy.hcl` and wires deployment inputs

---

## Repository Structure

```text
.
├── components.tfcomponent.hcl          # Component block: instantiates ./modules/aws-vpc per region
├── variables.tfcomponent.hcl           # Stack-level input variables
├── outputs.tfcomponent.hcl             # Stack-level outputs (all map-by-region)
├── providers.tfcomponent.hcl           # AWS provider, one config per region via for_each
├── .terraform-version                  # Pinned Terraform CLI version (1.13.4)
├── .terraform.lock.hcl                 # Provider dependency lock file — always commit this
├── modules/
│   └── aws-vpc/                        # Local child module — no provider blocks allowed here
│       ├── main.tf                     # VPC via terraform-aws-modules/vpc/aws 6.6.1
│       ├── variables.tf                # vpc_name, vpc_cidr, single_nat_gateway, tags
│       ├── outputs.tf                  # vpc_id, vpc_cidr_block, private_subnets, public_subnets, route_table_id
│       ├── providers.tf                # Provider pass-through (no config)
│       └── versions.tf                 # required_version >= 1.6.0, aws ~> 6.0
├── docs/
│   └── CONTRIBUTING.md                 # Contribution and code guidelines
└── .bob/                               # AI agent skills — do not edit
```

**Not in this repo (belongs in the orchestration repo):**
- `deployments.tfdeploy.hcl`
- `deployment_auto_approve.tfdeploy.hcl`
- `identity_token` blocks
- `deployment_group` blocks

---

## Stack Files Quick Reference

| File | Purpose |
|---|---|
| `components.tfcomponent.hcl` | Defines the `vpc` component, iterated `for_each = var.regions` |
| `variables.tfcomponent.hcl` | Stack inputs: `aws_identity_token` (ephemeral), `role_arn`, `vpc_name`, `vpc_cidr`, `regions`, `single_nat_gateway`, `tags` |
| `outputs.tfcomponent.hcl` | All outputs are `map` values keyed by region (e.g. `vpc_id["ca-central-1"]`) |
| `providers.tfcomponent.hcl` | One `aws` provider config per region; uses `assume_role_with_web_identity` |

---

## Child Module: `modules/aws-vpc`

Wraps the community module [`terraform-aws-modules/vpc/aws` v6.6.1](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest).

**What it provisions per region:**

| Resource | Detail |
|---|---|
| VPC | Custom CIDR, DNS hostnames enabled |
| Private Subnets | 3 subnets across 3 AZs (`cidrsubnet(cidr, 4, k)`), tagged `kubernetes.io/role/internal-elb` |
| Public Subnets | 3 subnets across 3 AZs (`cidrsubnet(cidr, 8, k+48)`), tagged `kubernetes.io/role/elb` |
| Internet Gateway | Attached to the VPC |
| NAT Gateway | One shared gateway (configurable via `single_nat_gateway`) |
| Route Tables | Public and private routing |

**Module inputs:**

| Variable | Type | Required | Description |
|---|---|---|---|
| `vpc_name` | `string` | Yes | VPC name and resource tag prefix |
| `vpc_cidr` | `string` | Yes | IPv4 CIDR block (validated with `cidrhost`) |
| `single_nat_gateway` | `bool` | No (default `true`) | Share one NAT GW — cost-saving, not HA |
| `tags` | `map(string)` | No (default `{}`) | Additional tags merged with `Blueprint = vpc_name` |

**Module outputs:** `vpc_id`, `vpc_cidr_block`, `private_subnets`, `public_subnets`, `route_table_id`

> **Rule:** Never add `provider` blocks inside `modules/aws-vpc/`. Providers are configured exclusively at the Stack level in `providers.tfcomponent.hcl` and passed down via the `providers` argument in `components.tfcomponent.hcl`.

---

## Code Guidelines

### Formatting

- Always run `terraform fmt -recursive` after generating or editing any `.tf` or `.hcl` file.
- Use 2-space indentation. Align `=` signs within the same block.

### Naming

- Use `snake_case` for all resource, variable, and output names.
- Do not include the resource type in the name: use `"aws_vpc" "main"`, not `"aws_vpc" "vpc_main"`.
- Wrap resource type and logical name in double quotes.

### Variables

- Every variable must have a `description` and explicit `type`.
- Prefix descriptions with `(Required)` or `(Optional)`.
- Add `validation` blocks for string inputs that have a constrained format (CIDR, ARN, etc.).
- Mark sensitive values with `sensitive = true`; mark ephemeral JWTs with `ephemeral = true`.

### Outputs

- Keep outputs in alphabetical order.
- Descriptions must be concise and factual — no `(Required)`/`(Optional)` prefixes.
- All Stack-level outputs in `outputs.tfcomponent.hcl` are maps keyed by region.

### Version Constraints

- Use the pessimistic constraint operator (`~>`) for providers and modules.
- Do not pin to an exact version (`= 6.0.0`) unless a known breaking issue requires it.
- Always commit `.terraform.lock.hcl` — it is the source of truth for provider versions.

---

## Multi-Region Pattern

The Stack deploys one VPC per region using `for_each = var.regions`:

- `provider "aws" "configurations"` creates one provider config per region.
- `component "vpc"` creates one VPC component per region.
- All Stack outputs aggregate results into a `map` keyed by region string.

---

## Security Rules

- **Never** hardcode AWS credentials, access keys, or secrets anywhere in the codebase.
- **Never** commit `.terraform/`, `*.tfstate`, `*.tfstate.backup`, or `*.tfvars` files with real values.
- **Never** add `deployments.tfdeploy.hcl` or `deployment_auto_approve.tfdeploy.hcl` to this repo — deployment configuration belongs in the orchestration repo.
- Use `sensitive = true` on all variables that carry secrets or tokens.
- Use `ephemeral = true` on variables that hold short-lived tokens (`aws_identity_token`).

---

## State Management

- State is managed natively by HCP Terraform for Stacks — do not use `terraform_remote_state` or `tfe_outputs`.
- Pass values between components directly via `component.<name>.<output>` references inside `components.tfcomponent.hcl`.

---

## Available Agent Skills

The `.bob/skills/` directory contains skill files that extend agent capabilities for this project:

| Skill | When to use |
|---|---|
| `terraform-stacks` | Creating or modifying Stack files (`.tfcomponent.hcl`) |
| `terraform-style-guide` | Generating or reviewing HCL following HashiCorp conventions |
| `terraform-test` | Writing `.tftest.hcl` test files for the `modules/aws-vpc` module |
| `terraform-policy` | Writing or converting Terraform policy files |
| `refactor-module` | Restructuring or extracting child modules |
| `terraform-search-import` | Discovering and importing existing AWS resources |
