locals {
  domain = "woile.dev"
}

#####################
# DNS CONFIGURATION #
#####################

# TODO

##########################
# Scaleway configuration #
##########################

data "scaleway_account_project" "homenet" {
  name            = "homenet"
  organization_id = var.scw_default_organization_id
}

resource "scaleway_iam_ssh_key" "ssh_keys" {
  project_id = data.scaleway_account_project.homenet.id
  for_each   = var.ssh_keys

  name       = each.key
  public_key = each.value
}


resource "scaleway_instance_ip" "public_ipv6_routed" {
  project_id = data.scaleway_account_project.homenet.id
  type       = "routed_ipv6"
}

resource "scaleway_instance_security_group" "www" {
  project_id              = data.scaleway_account_project.homenet.id
  name                    = "www"
  description             = "Simple security group for home server"
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"
  enable_default_security = false

  # SSH
  inbound_rule {
    action   = "accept"
    port     = "22"
    ip_range = "0.0.0.0/0"
  }
  inbound_rule {
    action   = "accept"
    port     = "22"
    ip_range = "::/0"
  }

  # HTTP
  inbound_rule {
    action = "accept"
    port   = "80"
  }

  # HTTP ipv6
  inbound_rule {
    action   = "accept"
    port     = "80"
    ip_range = "::/0"
  }

  # HTTPS
  inbound_rule {
    action = "accept"
    port   = "443"
  }

  # HTTPS ipv6
  inbound_rule {
    action   = "accept"
    port     = "443"
    ip_range = "::/0"
  }

  # ICMP: used for ping
  inbound_rule {
    action   = "accept"
    protocol = "ICMP"
  }

  # DNS
  inbound_rule {
    action   = "accept"
    port     = "53"
    ip_range = "0.0.0.0/0"
  }
  inbound_rule {
    action   = "accept"
    port     = "53"
    ip_range = "::/0"
  }

  # WireGuard Newt
  inbound_rule {
    action   = "accept"
    port     = "51820"
    ip_range = "0.0.0.0/0"
  }
  inbound_rule {
    action   = "accept"
    port     = "51820"
    ip_range = "::/0"
  }

  # WireGuard client
  inbound_rule {
    action   = "accept"
    port     = "21820"
    ip_range = "0.0.0.0/0"
  }
  inbound_rule {
    action   = "accept"
    port     = "21820"
    ip_range = "::/0"
  }
}

resource "scaleway_instance_server" "homenet_prime" {
  project_id = data.scaleway_account_project.homenet.id
  name       = "homenet_prime"
  type       = "STARDUST1-S"
  image      = "debian_trixie"
  tags       = ["home", "vpn"]

  ip_ids            = [scaleway_instance_ip.public_ipv6_routed.id]
  security_group_id = scaleway_instance_security_group.www.id

  root_volume {
    size_in_gb  = 10
    volume_type = "l_ssd"
  }

  # user_data = {
  #   cloud-init = templatefile("${path.module}/cloud-init.yaml", {})
  # }
}

####################
#      Storage     #
####################
resource "scaleway_object_bucket" "homenet-data" {
  project_id = data.scaleway_account_project.homenet.id
  name       = "homenet-data"

  versioning {
    enabled = true
  }

  tags = {
    "managed-by" = "opentofu"
    "usage"      = "backup"
  }
}
