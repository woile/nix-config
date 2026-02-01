output "homenet_ipv6_routed" {
  value = scaleway_instance_ip.public_ipv6_routed.address
}

output "homenet_backup_bucket_endpoint" {
  value = scaleway_object_bucket.homenet-data.endpoint
}

output "public_ips" {
  value = scaleway_instance_server.homenet_prime.public_ips
}
