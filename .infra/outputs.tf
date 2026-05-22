output "homenet_ipv6_routed" {
  value = scaleway_instance_ip.public_ipv6_routed.address
}

output "homenet_backup_bucket_endpoint" {
  value = scaleway_object_bucket.homenet-data.endpoint
}

output "public_ips" {
  value = scaleway_instance_server.amaru.public_ips
}

output "amaru_ssh" {
  value = scaleway_instance_server.amaru.public_ips.0.address
}
