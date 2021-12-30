# VPC OUTPUTS
output "vpc_self_link" {
  value = google_compute_network.vpc_network.self_link
}

# SUBNET OUTPUTS
output "bastion_subnet_self_link" {
  value = google_compute_subnetwork.bastion.self_link
}

output "public_subnet_self_link" {
  value = google_compute_subnetwork.public.self_link
}

output "private_subnet_self_link" {
  value = google_compute_subnetwork.private.self_link
}

# NAT OUTPUTS
output "public_nat_ip_1" {
  value = google_compute_address.nat_gateway_static_ip[0].address
}

output "public_nat_ip_2" {
  value = google_compute_address.nat_gateway_static_ip[1].address
}