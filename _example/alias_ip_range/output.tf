output "name" {
  value       = module.instance_template.name
  description = "An identifier for the resource with format"
}

output "id" {
  description = "List of id for instance template"
  value       = module.instance_template.id
}

output "self_link_unique" {
  value       = module.instance_template.self_link_unique
  description = "Self-link to the instance template"
}

output "self_link" {
  description = "List of self-links for instance template"
  value       = module.instance_template.self_link
}

output "available_zones" {
  description = "List of available zones in region"
  value       = module.instance_template.available_zones
}

output "tags_fingerprint" {
  value       = module.instance_template.tags_fingerprint
  description = " The unique fingerprint of the tags."
}

output "metadata_fingerprint" {
  value       = module.instance_template.metadata_fingerprint
  description = "An identifier for the resource with format"
}