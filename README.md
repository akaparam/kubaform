# KubaForm

Problem Statement:
- EKS is pricy
- EKS is overwhelming
- EKS PRICING IS OVERWHELMING

- To manage simple kubernetes workflow we just need a small cluster to be created in which our nodes could run!

Presenting a templatized kubernetes deployment which auto-configures EC2 instances as master and worker nodes where kubeadm and other tools are automatically installed...

Need to run a quick workflow? Just `terraform apply` and you're ready to go.

Done with your learning for the day? Want to save AWS costs? `terraform destroy` and it will de-provision everything.

No need to setup your own rig, or learn EKS... Just simply work with pre-configured tools (available as part of [User Data Scripts](./user_data/)) you need to explore the world of kubernetes.

The current configuration deploys the following architecture in AWS:

![KubaForm: Minified](./docs/assets/kf-lab.svg)

Now to provision these components the following terraform resources were defined in each module (generated with `terraform graph` rendered by `eraser.io`):

![KubaForm: Resource Map](./docs/assets/kf-lab-graph.svg)

## Pre-Requisite
1. AWS CLI with configured ACCESS_KEY_ID and SECRET_ACCESS_KEY
2. Terraform (>= v1.14)
3. (Optional) Namecheap / GoDaddy credentials if you want the separate DNS stack to manage domain records.

> If you don't have access to the API Key. Just add 50$ to your funds and they will let you enable API access. They tell you you can redeem it back but I didn't found an option in their portal to do so :)


## Provision

Kubaform ships with it's own default based on industry best practices / ensuring HA / yet keeping the costs to a minimal.

To get started with the lab core, simply:

```bash
cd kubaform
terraform init
terraform apply
```
Review the plan, type `yes`, and Terraform will provision the lab (ETA: 3 mins).

If you want to manage DNS records in a separate stack, use the domain stack after the main lab stack is up:

```bash
cd kubaform/domain
terraform init
terraform apply -var-file=secrets.tfvars
```

## Destroy

If you want to save costs, you can always de-provision resources after you're done playing around using:
```bash
terraform destroy # In the root directory
```
This will automatically remove all associations and de-provision all resources that were created with `apply`.

> Although, it is not needed to run the stacks in reverse order, but it is recommended that you do to ensure proper de-provisioning

## Docs

Find them [here](./docs/)

## Configuration

I get it, we all need customizations. I have tried my best to provide as much abstraction as possible while making sure to not overwhelm you guys.

> Note: While you cannot customize the architecture (with the current design). You can surely tweak around with more or less instances / subnets and upsizing storage volumes and instance class

To know more kindly, checkout the available configuration in [variables.tf](./variables.tf)

## Contribution

I would love to see more ideas implemented into this design.

Currently let's keep it `terraform` only. I know there are customizations we can think out of terraform's custom logic. But I would rather not expand to have different runtimes just yet. I have a few other things planned:
- Support for OpenTofu
- Implement other backends (for now it only has S3 as a backend and state locking)
- Setup CI/CD for drift detection and auto-apply (Use OIDC → assume IAM role - to authenticate terraform to AWS)
- Support for [setting up lab internals using Terraform instead of User Data scripts](https://registry.terraform.io/modules/terraform-module/release/helm/latest).