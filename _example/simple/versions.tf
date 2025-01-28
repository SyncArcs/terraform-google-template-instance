terraform {
  required_version = ">= 1.9.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.50.0, < 5.0.0"
    }
  }
}

