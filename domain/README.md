# KubaForm Domain Stack

This stack manages DNS mappings for the `kubaform` lab as a separate Terraform workspace.

## Purpose
- Keep Namecheap / GoDaddy DNS automation isolated from the main lab stack.
- Read `lab_ip` from the main stack state before applying.
- Fail early when the main stack is not provisioned.

## How to use

1. Run the main stack first from the `kubaform` root:

```bash
cd kubaform
terraform init
terraform apply
```

2. Switch to the domain stack folder:

```bash
cd kubaform/domain
terraform init
terraform apply -var-file=secrets.tfvars
```

## Configuration

The domain stack supports two providers:
- `namecheap`
- `godaddy`

Set `domain_provider` to the provider you want to use and supply the appropriate credentials.

Example variables file:

```hcl
root_domain = "param.sh"
list_of_subdomains = ["lab", "app"]
domain_provider = "namecheap"
namecheap_user_name = "YOUR_NAMECHEAP_USERNAME"
namecheap_api_user = "YOUR_NAMECHEAP_API_USER"
namecheap_api_key = "YOUR_NAMECHEAP_API_KEY"
```

For GoDaddy use:

```hcl
domain_provider = "godaddy"
godaddy_api_key = "YOUR_GODADDY_API_KEY"
godaddy_api_secret = "YOUR_GODADDY_API_SECRET"
```

## Notes

The domain stack reads `lab_ip` directly from the main stack state using Terraform remote state. If the output is missing, the domain stack will fail and prompt you to run the main stack first.
