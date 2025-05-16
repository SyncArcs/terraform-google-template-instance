output "id" {
  value       = join("", google_compute_instance_template.tpl[*].id)
  description = "An identifier for the resource with format"
}

output "name" {
  value       = join("", google_compute_instance_template.tpl[*].name)
  description = "An identifier for the resource with format"
}

output "tags_fingerprint" {
  value       = join("", google_compute_instance_template.tpl[*].tags_fingerprint)
  description = " The unique fingerprint of the tags."
}

output "metadata_fingerprint" {
  value       = join("", google_compute_instance_template.tpl[*].metadata_fingerprint)
  description = "An identifier for the resource with format"
}

output "self_link" {
  value       = join("", google_compute_instance_template.tpl[*].self_link)
  description = "An identifier for the resource with format"
}

output "self_link_unique" {
  value       = join("", google_compute_instance_template.tpl[*].self_link_unique)
  description = " A special URI of the created resource that uniquely identifies this instance template with the following format:"
}

output "available_zones" {
  value       = data.google_compute_zones.available.names
  description = "List of available zones in region"
}