variable "ssh_keys" {
  type        = map(string)
  description = "List of SSH public keys to access the resources"
  default = {
    "woile" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8RseI4gEC7JLYFwnW28OTZusYcriUC284CoK5FmS5I woile@aconcagua"
  }
}

variable "scw_access_key" {
  type        = string
  description = "Scaleway access key"
}

variable "scw_secret_key" {
  type        = string
  description = "Scaleway secret key"
}

variable "scw_default_organization_id" {
  type        = string
  description = "Scaleway defaul organization id"
}
