# Terraform + Azure AZ-104 Recert Practice

This repo contains minimal Terraform configurations for practicing Azure services
in a cost-safe way. **Most modules are plan-only** to avoid charges.

## Modules:
- rg/        → Resource group (safe to apply)
- storage/   → Storage account with static website + soft delete (safe to apply small files)
- network/   → VNet + NSG (plan-only)
- app/       → App Service (plan-only)
- containers/→ ACR + Container Instance (plan-only)
- backup/    → Recovery Services vault (plan-only)
- alerts/    → Activity Log alert + Action Group (safe to apply)
- iad/       → Azure AD users and groups (safe with a few users)

**Usage:**
```bash
terraform init
terraform plan -target=module.rg
terraform apply -target=module.storage
terraform destroy

