# Terraform + Azure AZ-104 Recertification Practice

This repository contains minimal **Terraform** configurations to practice **Azure** services in a **cost-safe** way.  
It is mainly designed for **practice and learning**, including several **failsafes** (such as `count = 0`) to avoid accidental creation of cost-generating resources.

> Origin: This project was created as part of my preparation for the **AZ-104 recertification** (25 direct Microsoft questions), and also to improve my Terraform skills (modules, variables, functions, etc.). While the recertification is more limited than the official AZ-104 exam with Pearson Vue, the content can be useful for the community to learn both topics.

---

## Repository structure

All Terraform code is located in the `terraform/` folder:

- **rg/** → Resource Group (**main** module to apply first)
- **budget/** → Creates a budget with an alert when spending exceeds **$1**
- **storage/** → Storage Account + SAS Key (default `count = 0`)
- **network/** → VNet + NSG + NICs + ASG
- **webapp/** → Plan + App Service
- **containers/** → Azure Container Registry + Container Instance (CI does not use the ACR by default)
- **backup/** → Recovery Services Vault + Policy
- **iad/** → Azure AD users, groups, and roles
- **staticwebapp/** → Static Web App (includes output with URL and token for GitHub Actions)
- **vm/** → Simple virtual machine
- **vmss/** → VM Scale Set (instances set to 0 by default)

---

## Static Web App

The `staticwebapp/` folder includes a **sample HTML** to deploy to the generated Static Web App.  
The `staticwebapp` module generates an **output** containing:
- The application URL
- A token to configure as a **GitHub Secret** for enabling automatic deployments with GitHub Actions.

---

## Variables and secrets

- The example file `secrets.tfvars.example` must be renamed to **`secrets.tfvars`**  
- It is already listed in `.gitignore` to prevent committing credentials.
- Variables such as `prefix` and `postfix` allow adding **randomness** (useful for unique names like Storage Accounts).

---

## Basic usage

```bash
# Initialize
terraform init

# Plan a specific module
terraform plan -target=module.rg

# Apply a specific module
terraform apply -target=module.storage

# Destroy created resources
terraform destroy

## Many modules are configured with count = 0 to avoid costs.
Only change them to values >0 if you actually intend to create the resource.

## Important notes

- Some modules can be deployed standalone (e.g., rg, budget, staticwebapp).
- Others, such as vm, vmss, or containers, depend on other modules (e.g., network or storage).
- The project is designed for zero or very low cost, but always review the plan before applying.
- Plan-only modules are configured to explore the infrastructure without deploying it.