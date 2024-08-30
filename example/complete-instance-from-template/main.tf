provider "google" {
  project = "local-concord-408802"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

#####==============================================================================
##### vpc module call.
#####==============================================================================
module "vpc" {
  source                                    = "SyncArcs/vpc/google"
  version                                   = "1.0.1"
  name                                      = "app"
  environment                               = "test"
  routing_mode                              = "REGIONAL"
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
}

#####==============================================================================
##### subnet module call.
#####==============================================================================
module "subnet" {
  source        = "SyncArcs/subnet/google"
  version       = "1.0.1"
  name          = "app"
  environment   = "test"
  subnet_names  = ["subnet-a"]
  gcp_region    = "asia-northeast1"
  network       = module.vpc.vpc_id
  ip_cidr_range = ["10.10.1.0/24"]
}

#####==============================================================================
##### firewall module call.
#####==============================================================================
module "firewall" {
  source        = "SyncArcs/firewall/google"
  version       = "1.0.1"
  name          = "app"
  environment   = "test"
  network       = module.vpc.vpc_id
  source_ranges = ["0.0.0.0/0"]

  allow = [
    { protocol = "tcp"
      ports    = ["22", "80"]
    }
  ]
}

data "google_compute_instance_template" "generic" {
  name = "instance-template-1"
}

#####==============================================================================
##### compute_instance module call.
#####==============================================================================
module "compute_instance" {
  source                   = "../../"
  name                     = "instance"
  environment              = "test"
  region                   = "asia-northeast1"
  zone                     = "asia-northeast1-a"
  subnetwork               = module.subnet.subnet_id
  instance_from_template   = true
  deletion_protection      = false
  service_account          = null
  enable_public_ip         = true ## public IP if enable_public_ip is true
  source_instance_template = data.google_compute_instance_template.generic.self_link
}