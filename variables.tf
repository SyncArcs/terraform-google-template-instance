variable "name" {
  type        = string
  default     = "test"
  description = "Name of the resource. Provided by the client when the resource is created. "
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] ."
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for the resource."
}

variable "managedby" {
  type        = string
  default     = "info@SyncArcs.com"
  description = "ManagedBy, eg 'info@SyncArcs.com'."
}

variable "repository" {
  type        = string
  default     = "https://github.com/SyncArcs/terraform-google-template-instance"
  description = "Terraform current module repo"
}

variable "machine_type" {
  type        = string
  default     = "e2-small"
  description = "Machine type to create, e.g. n1-standard-1"
}

variable "min_cpu_platform" {
  type        = string
  default     = null
  description = "Specifies a minimum CPU platform. Applicable values are the friendly names of CPU platforms, such as Intel Haswell or Intel Skylake. See the complete list: https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform"
}

variable "can_ip_forward" {
  type        = string
  default     = "false"
  description = "Enable IP forwarding, for NAT instances for example"
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "Network tags, provided as a list"
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels, provided as a map"
}

variable "preemptible" {
  type        = bool
  default     = false
  description = "Allow the instance to be preempted"
}

variable "automatic_restart" {
  type        = bool
  default     = true
  description = "(Optional) Specifies whether the instance should be automatically restarted if it is terminated by Compute Engine (not terminated by a user)."
}

variable "on_host_maintenance" {
  type        = string
  default     = "MIGRATE"
  description = "Instance availability Policy"
}

variable "region" {
  type        = string
  default     = null
  description = "Region where the instance template should be created."
}

variable "enable_nested_virtualization" {
  type        = bool
  default     = false
  description = "Defines whether the instance should have nested virtualization enabled."
}

variable "threads_per_core" {
  type        = number
  default     = null
  description = "The number of threads per physical core. To disable simultaneous multithreading (SMT) set this to 1."
}

variable "total_egress_bandwidth_tier" {
  type        = string
  default     = "DEFAULT"
  description = "Egress bandwidth tier setting for supported VM families"
  validation {
    condition     = contains(["DEFAULT", "TIER_1"], var.total_egress_bandwidth_tier)
    error_message = "Allowed values for bandwidth_tier are 'DEFAULT' or 'TIER_1'."
  }
}

variable "confidential_instance_type" {
  type        = string
  default     = null
  description = "Defines the confidential computing technology the instance uses. If this is set to \"SEV_SNP\", var.min_cpu_platform will be automatically set to \"AMD Milan\". See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#confidential_instance_type."
}

variable "spot" {
  type        = bool
  default     = false
  description = "Provision a SPOT instance"
}

variable "description" {
  type        = string
  default     = ""
  description = "The template's description"
}

variable "instance_description" {
  type        = string
  default     = ""
  description = "Description of the generated instances"
}

variable "spot_instance_termination_action" {
  type        = string
  default     = "STOP"
  description = "Action to take when Compute Engine preempts a Spot VM."
  validation {
    condition     = contains(["STOP", "DELETE"], var.spot_instance_termination_action)
    error_message = "Allowed values for spot_instance_termination_action are: \"STOP\" or \"DELETE\"."
  }
}

variable "nic_type" {
  type        = string
  default     = null
  description = "Valid values are \"VIRTIO_NET\", \"GVNIC\" or set to null to accept API default behavior."
  validation {
    condition     = var.nic_type == null || var.nic_type == "GVNIC" || var.nic_type == "VIRTIO_NET"
    error_message = "The \"nic_type\" variable must be set to \"VIRTIO_NET\", \"GVNIC\", or null to allow API default selection."
  }
}

variable "source_image" {
  type        = string
  default     = ""
  description = "Source disk image. If neither source_image nor source_image_family is specified, defaults to the latest public CentOS image."
}

variable "source_image_family" {
  type        = string
  default     = ""
  description = "Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public CentOS image."
}

variable "source_image_project" {
  type        = string
  default     = ""
  description = "Project where the source image comes from. The default project contains CentOS images."
}

variable "disk_size_gb" {
  type        = string
  default     = "20"
  description = "Boot disk size in GB"
}

variable "disk_type" {
  type        = string
  default     = ""
  description = "Boot disk type, can be either pd-ssd, local-ssd, or pd-standard"
}

variable "disk_labels" {
  type        = map(string)
  default     = {}
  description = "Labels to be assigned to boot disk, provided as a map"
}

variable "disk_encryption_key" {
  type        = string
  default     = null
  description = "The id of the encryption key that is stored in Google Cloud KMS to use to encrypt all the disks on this instance"
}

variable "auto_delete" {
  type        = string
  default     = "true"
  description = "Whether or not the boot disk should be auto-deleted"
}

variable "additional_disks" {
  type = list(object({
    disk_name    = string
    device_name  = string
    auto_delete  = bool
    boot         = bool
    disk_size_gb = number
    disk_type    = string
    disk_labels  = map(string)
  }))
  default     = []
  description = "List of maps of additional disks. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#disk_name"
}

variable "network" {
  type        = string
  default     = ""
  description = "The name or self_link of the network to attach this interface to. Use network attribute for Legacy or Auto subnetted networks and subnetwork for custom subnetted networks."
}

variable "subnetwork" {
  type        = string
  default     = ""
  description = "The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided."
}

variable "subnetwork_project" {
  type        = string
  default     = ""
  description = "The ID of the project in which the subnetwork belongs. If it is not provided, the provider project is used."
}

variable "network_ip" {
  type        = string
  default     = ""
  description = "Private IP address to assign to the instance if desired."
}

variable "stack_type" {
  type        = string
  default     = null
  description = "The stack type for this network interface to identify whether the IPv6 feature is enabled or not. Values are `IPV4_IPV6` or `IPV4_ONLY`. Default behavior is equivalent to IPV4_ONLY."
}

variable "additional_networks" {
  type = list(object({
    network            = string
    subnetwork         = string
    subnetwork_project = string
    network_ip         = string
    access_config = list(object({
      nat_ip       = string
      network_tier = string
    }))
    ipv6_access_config = list(object({
      network_tier = string
    }))
  }))
  default     = []
  description = "Additional network interface details for GCE, if any."
}

variable "startup_script" {
  type        = string
  default     = ""
  description = "User startup script to run when instances spin up"
}

variable "metadata" {
  type        = map(string)
  default     = {}
  description = "Metadata, provided as a map"
}

variable "service_account" {
  type = object({
    email  = string
    scopes = set(string)
  })
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account."
}

variable "enable_shielded_vm" {
  type        = bool
  default     = false
  description = "Whether to enable the Shielded VM configuration on the instance. Note that the instance image must support Shielded VMs. See https://cloud.google.com/compute/docs/images"
}

variable "shielded_instance_config" {
  type = object({
    enable_secure_boot          = bool
    enable_vtpm                 = bool
    enable_integrity_monitoring = bool
  })
  default = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  description = "Not used unless enable_shielded_vm is true. Shielded VM configuration for the instance."
}

variable "enable_confidential_vm" {
  type        = bool
  default     = false
  description = "Whether to enable the Confidential VM configuration on the instance. Note that the instance image must support Confidential VMs. See https://cloud.google.com/compute/docs/images"
}

variable "ipv6_access_config" {
  type = list(object({
    network_tier = string
  }))
  default     = []
  description = "IPv6 access configurations. Currently a max of 1 IPv6 access configuration is supported. If not specified, the instance will have no external IPv6 Internet access."
}

variable "gpu" {
  type = object({
    type  = string
    count = number
  })
  default     = null
  description = "GPU information. Type and count of GPU to attach to the instance template. See https://cloud.google.com/compute/docs/gpus more details"
}

variable "alias_ip_range" {
  type = object({
    ip_cidr_range         = string
    subnetwork_range_name = string
  })
  default     = null
  description = <<EOF
An array of alias IP ranges for this network interface. Can only be specified for network interfaces on subnet-mode networks.
ip_cidr_range: The IP CIDR range represented by this alias IP range. This IP CIDR range must belong to the specified subnetwork and cannot contain IP addresses reserved by system or used by other network interfaces. At the time of writing only a netmask (e.g. /24) may be supplied, with a CIDR format resulting in an API error.
subnetwork_range_name: The subnetwork secondary range name specifying the secondary range from which to allocate the IP CIDR range for this alias IP range. If left unspecified, the primary range of the subnetwork will be used.
EOF
}

variable "instance_template" {
  type        = bool
  default     = false
  description = "Instance template self_link used to create compute instances"
}

variable "resource_policies" {
  type        = list(string)
  default     = []
  description = "(Optional) A list of short names or self_links of resource policies to attach to the instance. Modifying this list will cause the instance to recreate. Currently a max of 1 resource policy is supported."
}

variable "enable_public_ip" {
  type        = bool
  default     = false
  description = "public IP if enable_public_ip is true for the instance."
}