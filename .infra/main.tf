locals {
  domain = "woile.dev"
}

#####################
# DNS CONFIGURATION #
#####################

data "netlify_dns_zone" "woile_dev" {
  name = local.domain
}

resource "netlify_dns_record" "auth_ipv6" {
  zone_id  = data.netlify_dns_zone.woile_dev.id
  hostname = "auth"
  type     = "AAAA"
  value    = scaleway_instance_ip.public_ipv6_routed.address
  ttl      = 3600
}

resource "netlify_dns_record" "vpn_ipv6" {
  zone_id  = data.netlify_dns_zone.woile_dev.id
  hostname = "vpn"
  type     = "AAAA"
  value    = scaleway_instance_ip.public_ipv6_routed.address
  ttl      = 3600
}

resource "netlify_dns_record" "auth_ipv4" {
  zone_id  = data.netlify_dns_zone.woile_dev.id
  hostname = "auth"
  type     = "A"
  value    = scaleway_instance_ip.public_ip_routed.address
  ttl      = 3600
}

resource "netlify_dns_record" "vpn_ipv4" {
  zone_id  = data.netlify_dns_zone.woile_dev.id
  hostname = "vpn"
  type     = "A"
  value    = scaleway_instance_ip.public_ip_routed.address
  ttl      = 3600
}

################
# Scaleway DNS #
################
data "scaleway_domain_zone" "woile_eu_root" {
  domain    = "woile.eu"
  subdomain = ""
}

resource "scaleway_domain_record" "woile_eu_ownership" {
  dns_zone = data.scaleway_domain_zone.woile_eu_root.id
  name     = "_git-pages-repository"
  type     = "TXT"
  data     = "https://codeberg.org/woile/blog.git"
  ttl      = 3600
}

resource "scaleway_domain_record" "woile_eu_apex" {
  dns_zone = data.scaleway_domain_zone.woile_eu_root.id
  name     = ""
  type     = "ALIAS"
  data     = "grebedoc.dev."
  ttl      = 3600
}

resource "scaleway_domain_record" "vpn_ipv4_eu_tld" {
  dns_zone = data.scaleway_domain_zone.woile_eu_root.id
  name     = "vpn"
  type     = "A"
  data     = scaleway_instance_ip.public_ip_routed.address
  ttl      = 3600
}

resource "scaleway_domain_record" "vpn_ipv6_eu_tld" {
  dns_zone = data.scaleway_domain_zone.woile_eu_root.id
  name     = "vpn"
  type     = "AAAA"
  data     = scaleway_instance_ip.public_ipv6_routed.address
  ttl      = 3600
}

resource "scaleway_domain_record" "auth_ipv4_eu_tld" {
  dns_zone = data.scaleway_domain_zone.woile_eu_root.id
  name     = "auth"
  type     = "A"
  data     = scaleway_instance_ip.public_ip_routed.address
  ttl      = 3600
}

resource "scaleway_domain_record" "auth_ipv6_eu_tld" {
  dns_zone = data.scaleway_domain_zone.woile_eu_root.id
  name     = "auth"
  type     = "AAAA"
  data     = scaleway_instance_ip.public_ipv6_routed.address
  ttl      = 3600
}

resource "scaleway_domain_record" "at_proto_woile_eu" {
  dns_zone = data.scaleway_domain_zone.woile_eu_root.id
  name     = "_atproto"
  type     = "TXT"
  data     = "did=did:plc:76loxjswafa7wb4r6zbiii4e"
  ttl      = 3600
}

###################
# Scaleway Server #
###################

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

resource "scaleway_instance_ip" "public_ip_routed" {
  project_id = data.scaleway_account_project.homenet.id
  type       = "routed_ipv4"
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

  # Kanidm LDAPS
  inbound_rule {
    action   = "accept"
    port     = "3636"
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

resource "scaleway_instance_server" "amaru" {
  project_id = data.scaleway_account_project.homenet.id
  name       = "amaru"
  type       = "STARDUST1-S"
  # type = "DEV1-S"

  # command to run console.scaleway.com/:
  # `scw marketplace image list`
  image = "debian_trixie"
  tags  = ["home", "vpn", "tofu"]

  ip_ids            = [scaleway_instance_ip.public_ip_routed.id, scaleway_instance_ip.public_ipv6_routed.id]
  security_group_id = scaleway_instance_security_group.www.id

  root_volume {
    size_in_gb  = 10
    volume_type = "l_ssd"
  }

  # # only executed on first boot
  user_data = {
    cloud-init = templatefile("${path.module}/cloud-init.yaml", {})
  }
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
