.PHONY: lab-init lab-apply lab-destroy domain-init domain-apply domain-destroy

# Lab stack commands
lab-init:
	cd lab && terraform init

lab-apply:
	cd lab && terraform apply -var-file=inputs.tfvars

lab-destroy:
	cd lab && terraform destroy -var-file=inputs.tfvars

# Domain stack commands
domain-init:
	cd domain && terraform init

domain-apply:
	cd domain && terraform apply -var-file=inputs.tfvars

domain-destroy:
	cd domain && terraform destroy -var-file=inputs.tfvars