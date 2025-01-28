provider "google" {
  project = "soy-smile-435017-c5"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

#####==============================================================================
##### vpc module call.
#####==============================================================================
module "vpc" {
  source                                    = "git::https://github.com/SyncArcs/terraform-google-vpc.git?ref=v1.0.1"
  name                                      = "app12"
  environment                               = "test"
  routing_mode                              = "REGIONAL"
  mtu                                       = 1500
  network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"
}

#####==============================================================================
##### subnet module call.
#####==============================================================================
module "subnet" {
  source        = "git::https://github.com/SyncArcs/terraform-google-subnet.git?ref=v1.0.0"
  name          = "app"
  environment   = "test"
  subnet_names  = ["subnet-a"]
  network       = module.vpc.vpc_id
  ip_cidr_range = ["10.10.1.0/24"]
}

#####==============================================================================
##### firewall module call.
#####==============================================================================
module "firewall" {
  source      = "git::https://github.com/SyncArcs/terraform-google-firewall.git?ref=v1.0.0"
  name        = "app"
  environment = "test"
  network     = module.vpc.vpc_id
  ingress_rules = [
    {
      name          = "allow-tcp-http-ingress"
      description   = "Allow TCP, HTTP ingress traffic"
      disabled      = false
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22", "80"]
        }
      ]
    }
  ]
}

#####==============================================================================
##### Single-service-account module call .
#####==============================================================================
module "service-account" {
  source = "git::https://github.com/SyncArcs/terraform-google-service-account.git?ref=v1.0.0"
  service_account = [
    {
      name          = "test"
      display_name  = "Single Service Account"
      description   = "Single Account Description"
      roles         = ["roles/viewer"] # Single role
      generate_keys = false
    }
  ]
}

#####==============================================================================
##### instance_template module call.
#####==============================================================================
module "instance_template" {
  source            = "./../../"
  name              = "alias-ip-range"
  environment       = "test"
  instance_template = true
  subnetwork        = module.subnet.subnet_id

  service_account = {
    email  = module.service-account.account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"] # Example scopes
  }

  alias_ip_range = {
    ip_cidr_range         = "/24"
    subnetwork_range_name = module.subnet.subnet_name
  }
}
