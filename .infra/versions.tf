terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.68.0"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    bucket                      = "homenet-tf-state"
    key                         = "terraform.tfstate"
    region                      = "nl-ams"
    endpoint                    = "https://s3.nl-ams.scw.cloud"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true # uncomment on tf 1.6
  }
}

provider "scaleway" {
  zone            = "pl-waw-2"
  region          = "pl-waw"
  access_key      = var.scw_access_key
  secret_key      = var.scw_secret_key
  organization_id = var.scw_default_organization_id
}
