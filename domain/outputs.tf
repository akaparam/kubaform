output "lab_url" {
  description = "Public URL for the lab environment."
  value       = "http://${var.list_of_subdomains[0]}.${var.root_domain}"
}