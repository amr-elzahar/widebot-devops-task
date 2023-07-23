//CREATE PRIVATE GKE
resource "google_container_cluster" "private-gke" {
  name                     = var.cluster_name
  location                 = var.zone
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.web-app-vpc.id
  subnetwork               = google_compute_subnetwork.private-subnet.id

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.101.0.0/16"
    services_ipv4_cidr_block = "10.102.0.0/16"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = google_compute_subnetwork.public-subnet.ip_cidr_range
    }
  }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "10.100.100.0/28"
  }
}

// CREATE NODE POOL
resource "google_container_node_pool" "private-gke-node-pool" {
  name              = "private-gke-node-pool"
  location          = google_container_cluster.private-gke.location
  node_locations    = [var.var.zone]
  cluster           = google_container_cluster.private-gke.id
  node_count        = 1
  max_pods_per_node = 110

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  node_config {
    preemptible  = true
    machine_type = var.node_pool_machine_type
    disk_size_gb = var.node_pool_disk_size
    disk_type    = var.node_pool_disk_type
    image_type   = var.node_pool_image_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}