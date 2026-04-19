output "lab_ip" {
  description = "Public IP address imported from the main stack."
  value       = local.lab_ip
}

output "domain_provider" {
  description = "DNS provider selected for this stack."
  value       = var.domain_provider
}
