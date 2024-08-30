output "id" {
  value       = module.compute_instance.id
  description = "An identifier for the resource with format"
}

output "template_id" {
  value       = module.instance_template.template_id
  description = "An identifier for the resource with format"
}

output "metadata_fingerprint" {
  value       = module.compute_instance.metadata_fingerprint
  description = "The unique fingerprint of the metadata."
}

output "template_tags_fingerprint" {
  value       = module.instance_template.template_tags_fingerprint
  description = " The unique fingerprint of the tags."
}

output "template_metadata_fingerprint" {
  value       = module.instance_template.template_metadata_fingerprint
  description = "An identifier for the resource with format"
}

output "self_link" {
  value       = module.compute_instance.self_link
  description = " The URI of the created resource."
}

output "template_self_link" {
  value       = module.instance_template.template_self_link
  description = "An identifier for the resource with format"
}

output "self_link_unique" {
  value       = module.instance_template.self_link_unique
  description = " A special URI of the created resource that uniquely identifies this instance template with the following format:"
}

output "instances_self_links" {
  description = "List of self-links for compute instances"
  value       = module.compute_instance.instances_self_links
}