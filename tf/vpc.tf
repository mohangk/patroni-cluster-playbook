# VPC
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.subnet_cidr
  private_ip_google_access = true
}

# NAT 
resource "google_compute_router" "router" {
  name    = "nat-router"
  description = "Router to be used by NAT"
  network = google_compute_network.vpc.name
}

resource "google_compute_router_nat" "nat" {
  name                               = "router-nat"
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

}

#Firewall rules
resource "google_compute_firewall" "allowed-ports-internal2" {
  name    = "allowed-ports-internal2"
  description = "Accepts ssh and http from local" 
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = [22,2379,2380,5432]
  }

  source_ranges           = [google_compute_subnetwork.subnet.ip_cidr_range]
}

#Firewall rules allow-ssh
resource "google_compute_firewall" "allow-ssh-from-iap" {
  name    = "allow-ssh-ingress-from-iap"
  description = "Allows  IAP tunneling" 
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = [22]
  }
  source_ranges           = ["35.235.240.0/20"]
}

output "vpc_name" {
  value       = google_compute_network.vpc.name
  description = "VPC Name"
}
