// CREATE VPC
resource "google_compute_network" "web-app-vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

// CREATE VPC FIREWALLS
resource "google_compute_firewall" "vpc-firewall" {
  name          = "vpc-firewall"
  network       = google_compute_network.web-app-vpc.id
  source_ranges = [google_compute_subnetwork.public-subnet.ip_cidr_range]

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "6379", "27017", "1433"]
  }
}

// CREATE PUBLIC SUBNET
resource "google_compute_subnetwork" "public-subnet" {
  name                     = var.public_subnet_name
  region                   = var.region
  ip_cidr_range            = var.public_subnet_cidr
  network                  = google_compute_network.web-app-vpc.id
  private_ip_google_access = true
}

// CREATE PRIVATE SUBNET
resource "google_compute_subnetwork" "private-subnet" {
  name                     = var.private_subnet_name
  region                   = var.region
  ip_cidr_range            = var.private_subnet_cidr
  network                  = google_compute_network.web-app-vpc.id
  private_ip_google_access = true
}

// CREATE PUBLIC ROUTER
resource "google_compute_router" "public-router" {
  name    = "public-router-nat"
  network = google_compute_network.web-app-vpc.name
  region  = var.region
}

// CREATE PUBLIC NAT GATEWAY
resource "google_compute_router_nat" "management-nat" {
  name                               = "public-nat"
  router                             = google_compute_router.public-router.name
  region                             = google_compute_router.public-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.public-subnet.name
    source_ip_ranges_to_nat = [var.public_subnet_cidr]
  }
}

// CREATE VM SERVICE ACCOUNT
resource "google_service_account" "vm-service-account" {
  account_id   = "vm-service-account"
  display_name = "VM service account"
}

// CREATE VM ROLE
resource "google_project_iam_member" "vm-sa-role" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.vm-service-account.email}"
}

// CREATE VM INSTANCE
resource "google_compute_instance" "public-vm" {
  name         = "public-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.web-app-vpc.id
    subnetwork = google_compute_subnetwork.public-subnet.id

    access_config {
      // To make it puplic
      
    }
  }

  service_account {
    email = google_service_account.vm-service-account.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  metadata_startup_script = file("script.sh")

  metadata = {
    Name = "Public VM"
  }
}