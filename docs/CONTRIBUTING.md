# Contributing

Thank you for your interest in contributing. This repository is a **reusable Terraform Stack component** (Pattern A) that provisions an AWS VPC using OIDC workload identity authentication. It contains component definitions only — no deployment configuration. Please review these guidelines before contributing.

## Architecture Paradigm: Reusable Stack Component

This repository follows the **Pattern A** Terraform Stacks design: it defines the component contract (variables, providers, component block, outputs) and a local child module. Deployment configuration (`deployments.tfdeploy.hcl`, identity tokens, deployment groups) belongs in a separate Stack orchestration repository that references this component.

* **No Deployment Files Here:** Do not add `deployments.tfdeploy.hcl`, `deployment_auto_approve.tfdeploy.hcl`, or `identity_token` blocks to this repository.
* **No Local State or CLI Applies:** Do not run `terraform apply` locally. All deployments are triggered from the consuming Stack orchestration repo via HCP Terraform.
* **Dynamic Credentials:** Authentication uses AWS OIDC workload identity. HCP Terraform generates an ephemeral JWT at runtime, exchanged for temporary AWS credentials via `assume_role_with_web_identity`. No static credentials are stored.

## Development Workflow

1. **Fork & Branch:** Create a branch for your feature or bug fix.
2. **Write Code:** Modify the Stack configuration files (`.tfcomponent.hcl`) or the `modules/aws-vpc` child module. Follow the styling guidelines in `AGENTS.md`.
3. **No Provider Blocks in Modules:** Never add `provider` blocks inside `modules/aws-vpc/`. Providers are configured exclusively in `providers.tfcomponent.hcl` and passed down via the `providers` argument in `components.tfcomponent.hcl`.
4. **Format:** The `terraform.yml` workflow runs `terraform fmt -recursive` on pull requests and pushes formatting fixes automatically using the [`GitHubAction-TerraformFormat`](https://github.com/benoitblais-hashicorp-demo/GitHubAction-TerraformFormat) action. Run `terraform fmt -recursive` locally before opening a PR to avoid an extra commit.
5. **Open a Pull Request:** Fill out the provided PR template. A patch version tag is created automatically when the PR is merged.

## CI/CD Workflows

| Workflow | Trigger | What it does |
|---|---|---|
| `terraform.yml` | Pull request | Runs `terraform fmt -recursive`; pushes auto-fix commit if formatting changes are needed |
| `linter.yml` | Pull request | Runs super-linter: tflint, Markdown, YAML, JSON, GitHub Actions validation |
| `tag_release.yml` | PR merged | Creates a semantic patch version tag (`vX.Y.Z`) automatically |

**tflint rules enforced** (see `.github/linters/.tflint.hcl`): `terraform_naming_convention`, `terraform_documented_variables`, `terraform_documented_outputs`, `terraform_required_version`, `terraform_required_providers`, `terraform_module_pinned_source`, `terraform_typed_variables`, `terraform_unused_declarations`.

## Code Guidelines

* **Minimalism:** Favor readability and simplicity over complex abstractions.
* **Variable Descriptions:** Every variable must have a `description` and explicit `type`. Prefix descriptions with `(Required)` or `(Optional)`. Add `validation` blocks for inputs with constrained formats (CIDR, ARN, etc.).
* **Version Constraints:** Use the pessimistic operator (`~>`) for provider and module versions. Do not pin to an exact version unless a known issue requires it.
* **Naming Conventions:** Use `snake_case` for all resource, variable, and output names. Do not include the resource type in the name (e.g. `resource "aws_vpc" "main"`, not `resource "aws_vpc" "vpc_main"`).
* **Outputs:** Keep outputs alphabetical. Use concise factual descriptions without `(Required)`/`(Optional)` prefixes.
* **Lock File:** Always commit `.terraform.lock.hcl` — it is the authoritative record of pinned provider versions.

## Security

* Never commit `.terraform/` directories, `*.tfstate`, `*.tfstate.backup`, or `*.tfvars` files containing real values.
* Never hardcode AWS credentials, access keys, role ARNs, or any secrets in source files.
* Mark sensitive variables with `sensitive = true`. Mark ephemeral tokens (e.g. `aws_identity_token`) with `ephemeral = true`.
* Authentication is exclusively via OIDC workload identity — no long-lived credentials are used or stored.

## Documentation

* Edit `README.md` directly — it is manually maintained, not auto-generated.
* Keep the inputs, outputs, and requirements tables in `README.md` in sync when adding or changing variables, outputs, or provider/module versions.
