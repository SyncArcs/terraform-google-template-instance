module "labels" {
  source      = "git::https://github.com/SyncArcs/terraform-google-labels.git?ref=v1.0.0"
  name        = var.name
  environment = var.environment
  label_order = var.label_order
  managedby   = var.managedby
  repository  = var.repository
  extra_tags  = var.extra_tags
}

data "google_client_config" "current" {}

data "google_compute_zones" "available" {
  project = data.google_client_config.current.project
  region  = var.region
}

locals {
  source_image         = var.source_image != "" ? var.source_image : "ubuntu-2204-jammy-v20230908"
  source_image_family  = var.source_image_family != "" ? var.source_image_family : "ubuntu-2204-lts"
  source_image_project = var.source_image_project != "" ? var.source_image_project : "ubuntu-os-cloud"

  boot_disk = [
    {
      source_image = var.source_image != "" ? format("${local.source_image_project}/${local.source_image}") : format("${local.source_image_project}/${local.source_image_family}")
      disk_size_gb = var.disk_size_gb
      disk_type    = var.disk_type
      disk_labels  = var.disk_labels
      auto_delete  = var.auto_delete
      boot         = "true"
    },
  ]
  all_disks              = concat(local.boot_disk, var.additional_disks)
  shielded_vm_configs    = var.enable_shielded_vm ? [true] : []
  gpu_enabled            = var.gpu != null
  alias_ip_range_enabled = var.alias_ip_range != null
  on_host_maintenance = (
    var.preemptible || var.enable_confidential_vm || local.gpu_enabled
    ? "TERMINATE"
    : var.on_host_maintenance
  )
  min_cpu_platform = var.confidential_instance_type == "SEV_SNP" ? "AMD Milan" : var.min_cpu_platform

  automatic_restart = (
    var.preemptible || var.spot ? false : var.automatic_restart
  )
  preemptible = (
    var.preemptible || var.spot ? true : false
  )
}

#####==============================================================================
##### Manages a VM instance template resource within GCE.
#####==============================================================================
resource "google_compute_instance_template" "tpl" {
  count                   = var.instance_template ? 1 : 0
  name_prefix             = format("%s-%s", module.labels.id, (count.index))
  project                 = data.google_client_config.current.project
  description             = var.description
  instance_description    = var.instance_description
  machine_type            = var.machine_type
  labels                  = var.labels
  metadata                = var.metadata
  tags                    = var.tags
  can_ip_forward          = var.can_ip_forward
  metadata_startup_script = var.startup_script
  region                  = var.region
  min_cpu_platform        = local.min_cpu_platform
  resource_policies       = var.resource_policies
  dynamic "disk" {
    for_each = local.all_disks
    content {
      auto_delete       = lookup(disk.value, "auto_delete", null)
      boot              = lookup(disk.value, "boot", null)
      device_name       = lookup(disk.value, "device_name", null)
      disk_name         = lookup(disk.value, "disk_name", null)
      disk_size_gb      = lookup(disk.value, "disk_size_gb", lookup(disk.value, "disk_type", null) == "local-ssd" ? "375" : null)
      disk_type         = lookup(disk.value, "disk_type", null)
      interface         = lookup(disk.value, "interface", lookup(disk.value, "disk_type", null) == "local-ssd" ? "NVME" : null)
      mode              = lookup(disk.value, "mode", null)
      source            = lookup(disk.value, "source", null)
      source_image      = lookup(disk.value, "source_image", null)
      source_snapshot   = lookup(disk.value, "source_snapshot", null)
      type              = lookup(disk.value, "disk_type", null) == "local-ssd" ? "SCRATCH" : "PERSISTENT"
      labels            = lookup(disk.value, "disk_labels", null)
      resource_policies = lookup(disk.value, "resource_policies", [])

      dynamic "disk_encryption_key" {
        for_each = compact([var.disk_encryption_key == null ? null : 1])
        content {
          kms_key_self_link = var.disk_encryption_key
        }
      }
    }
  }

  dynamic "service_account" {
    for_each = var.service_account == null ? [] : [var.service_account]
    content {
      email  = lookup(service_account.value, "email", null)
      scopes = lookup(service_account.value, "scopes", null)
    }
  }

  network_interface {
    network            = var.network
    subnetwork         = var.subnetwork
    subnetwork_project = var.subnetwork_project
    network_ip         = length(var.network_ip) > 0 ? var.network_ip : null
    nic_type           = var.nic_type
    stack_type         = var.stack_type
    dynamic "access_config" {
      for_each = var.enable_public_ip ? [1] : []
      content {
        # Add access_config settings here if needed
      }
    }

    dynamic "ipv6_access_config" {
      for_each = var.ipv6_access_config
      content {
        network_tier = ipv6_access_config.value.network_tier
      }
    }

    dynamic "alias_ip_range" {
      for_each = local.alias_ip_range_enabled ? [var.alias_ip_range] : []
      content {
        ip_cidr_range         = alias_ip_range.value.ip_cidr_range
        subnetwork_range_name = alias_ip_range.value.subnetwork_range_name
      }
    }
  }

  dynamic "network_interface" {
    for_each = var.additional_networks
    content {
      network            = network_interface.value.network
      subnetwork         = network_interface.value.subnetwork
      subnetwork_project = network_interface.value.subnetwork_project
      network_ip         = length(network_interface.value.network_ip) > 0 ? network_interface.value.network_ip : null
      nic_type           = network_interface.value.nic_type
      stack_type         = network_interface.value.stack_type
      queue_count        = network_interface.value.queue_count
      dynamic "access_config" {
        for_each = network_interface.value.access_config
        content {
          nat_ip       = access_config.value.nat_ip
          network_tier = access_config.value.network_tier
        }
      }

      dynamic "ipv6_access_config" {
        for_each = network_interface.value.ipv6_access_config
        content {
          network_tier = ipv6_access_config.value.network_tier
        }
      }

      dynamic "alias_ip_range" {
        for_each = network_interface.value.alias_ip_range
        content {
          ip_cidr_range         = alias_ip_range.value.ip_cidr_range
          subnetwork_range_name = alias_ip_range.value.subnetwork_range_name
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = "true"
  }

  scheduling {
    automatic_restart           = local.automatic_restart
    instance_termination_action = var.spot ? var.spot_instance_termination_action : null
    on_host_maintenance         = local.on_host_maintenance
    preemptible                 = local.preemptible
    provisioning_model          = var.spot ? "SPOT" : null
  }

  advanced_machine_features {
    enable_nested_virtualization = var.enable_nested_virtualization
    threads_per_core             = var.threads_per_core
  }

  dynamic "shielded_instance_config" {
    for_each = local.shielded_vm_configs
    content {
      enable_secure_boot          = lookup(var.shielded_instance_config, "enable_secure_boot", shielded_instance_config.value)
      enable_vtpm                 = lookup(var.shielded_instance_config, "enable_vtpm", shielded_instance_config.value)
      enable_integrity_monitoring = lookup(var.shielded_instance_config, "enable_integrity_monitoring", shielded_instance_config.value)
    }
  }

  confidential_instance_config {
    enable_confidential_compute = var.enable_confidential_vm
  }

  network_performance_config {
    total_egress_bandwidth_tier = var.total_egress_bandwidth_tier
  }

  dynamic "guest_accelerator" {
    for_each = local.gpu_enabled ? [var.gpu] : []
    content {
      type  = guest_accelerator.value.type
      count = guest_accelerator.value.count
    }
  }
}
