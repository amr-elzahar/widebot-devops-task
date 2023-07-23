# Define the Redis Deployment
resource "kubernetes_deployment_v1" "redis" {
  metadata {
    name = "redis"
  }

  spec {
    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          name  = "redis"
          image = "redis"
          ports {
            container_port = 6379
          }
          volume_mount {
            name       = "redis-data"
            mount_path = "/data"
          }
        }

        volume {
          name = "redis-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.redis.metadata[0].name
          }
        }
      }
    }
  }
}

# Define the Redis Service
resource "kubernetes_service_v1" "redis" {
  metadata {
    name = "redis"
  }

  spec {
    selector = {
      app = "redis"
    }
    port {
      port        = 6379
      target_port = 6379
    }
    type = "ClusterIP"
  }
}

# Define the Redis PersistentVolume
resource "kubernetes_persistent_volume_v1" "redis" {
  metadata {
    name = "redis-pv"
  }

  spec {
    capacity {
      storage = "5Gi"
    }
    volume_mode      = "Filesystem"
    access_modes     = ["ReadWriteOnce"]
    reclaim_policy   = "Retain"
    storage_class_name = "my-storage-class"
    gce_persistent_disk {
      pd_name = "redis-disk"
      fs_type = "ext4"
    }
  }
}

# Define the Redis PersistentVolumeClaim
resource "kubernetes_persistent_volume_claim_v1" "redis" {
  metadata {
    name = "redis-pvc"
  }

  spec {
    storage_class_name = "my-storage-class"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests {
        storage = "5Gi"
      }
    }
  }
}
