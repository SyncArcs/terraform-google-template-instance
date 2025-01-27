output "name" {
  value       = module.simple_template.name
  description = "An identifier for the resource with format"
}

output "id" {
  description = "List of id for instance template"
  value       = module.simple_template.id
}

output "self_link_unique" {
  value       = module.simple_template.self_link_unique
  description = "Self-link to the instance template"
}

output "self_link" {
  description = "List of self-links for instance template"
  value       = module.simple_template.self_link
}

output "available_zones" {
  description = "List of available zones in region"
  value       = module.simple_template.available_zones
}

output "tags_fingerprint" {
  value       = module.simple_template.tags_fingerprint
  description = " The unique fingerprint of the tags."
}

output "metadata_fingerprint" {
  value       = module.simple_template.metadata_fingerprint
  description = "An identifier for the resource with format"
}