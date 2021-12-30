# Local Input Variables
locals {
  owners               = var.network_settings.general.owner
  environment          = var.network_settings.general.environment
  project              = var.network_settings.general.project_name
  resource_name_prefix = "${local.project}-${local.environment}"
  common_tags = {
      project     = local.project
      owners      = local.owners
      environment = local.environment
  }
}


# VPC
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "vpc_network" {
  name                            = "${local.resource_name_prefix}-network"
  auto_create_subnetworks         = var.network_settings.vpc.auto_create_subnetworks
  delete_default_routes_on_create = var.network_settings.vpc.delete_default_routes_on_create
}


# BASTION SUBNET
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "bastion" {
  name                     = "bastion"
  region                   = var.network_settings.general.region
  ip_cidr_range            = var.network_settings.bastion_subnet.ip_cidr_range
  network                  = google_compute_network.vpc_network.self_link
  purpose                  = "PRIVATE"
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = var.network_settings.bastion_subnet.private_ip_google_access 
}

# BASTION SUBNET INTERNET ROUTE
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route
resource "google_compute_route" "bastion_internet_route" {
  name             = "bastion-internet-route"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc_network.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
  tags             = ["bastion-internet"]
}


# PUBLIC SUBNET
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "public" {
  name                     = "public"
  region                   = var.network_settings.general.region
  ip_cidr_range            = var.network_settings.public_subnet.ip_cidr_range
  network                  = google_compute_network.vpc_network.self_link
  purpose                  = "PRIVATE"
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = var.network_settings.public_subnet.private_ip_google_access 
}

# PUBLIC SUBNET INTERNET ROUTE
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route
resource "google_compute_route" "public_internet_route" {
  name             = "public-internet-route"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc_network.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
  tags             = ["public-internet"]
}


# PRIVATE SUBNET
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "private" {
  name                     = "private"
  region                   = var.network_settings.general.region
  ip_cidr_range            = var.network_settings.private_subnet.ip_cidr_range
  network                  = google_compute_network.vpc_network.self_link
  purpose                  = "PRIVATE"
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = var.network_settings.private_subnet.private_ip_google_access 
}

# PRIVATE SUBNET INTERNET ROUTE
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route
resource "google_compute_route" "private_internet_route" {
  name             = "private-internet-route"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc_network.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
  tags             = ["private-internet"]
}


# PRIVATE NAT ROUTER
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router#nested_advertised_ip_ranges
resource "google_compute_router" "private_interet_router" {
  name    = "private-internet-router"
  region  = var.network_settings.general.region
  network = google_compute_network.vpc_network.self_link
}

# PUBLIC STATIC IP
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
resource "google_compute_address" "nat_gateway_static_ip" {
  count  = 2
  name   = "nat-gateway-static-ip-${count.index}"
  region = var.network_settings.general.region
}

# PRIVATE CLOUD NAT
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
resource "google_compute_router_nat" "private_nat" {
  name                               = "private-nat"
  router                             = google_compute_router.private_interet_router.name
  region                             = google_compute_router.private_interet_router.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ips                            = google_compute_address.nat_gateway_static_ip.*.self_link

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}