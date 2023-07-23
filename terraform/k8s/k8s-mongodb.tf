# StatefulSet resource for MongoDB
resource "kubernetes_stateful_set_v1" "mongodb" {
  metadata {
    name = "mongodb"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mongodb"
      }
    }

    template {
      metadata {
        labels = {
          app = "mongodb"
        }
      }

      spec {
        termination_grace_period_seconds = 10

        container {
          name  = "mongodb"
          image = "mongo"
          ports {
            container_port = 27017
          }

          volume_mount {
            name       = "mongodb-volume"
            mount_path = "/data/db"
          }
        }

        volume {
          name = "mongodb-volume"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mongodb_pvc.metadata.0.name
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "mongodb-pvc"
      }

      spec {
        access_modes = ["ReadWriteOnce"]
        storage_class_name = "my-storage-class"

        resources {
          requests = {
            storage = "5Gi"
          }
        }
      }
    }
  }
}

# Service resource for MongoDB
resource "kubernetes_service_v1" "mongodb" {
  metadata {
    name = "mongodb"
  }

  spec {
    selector = {
      app = "mongodb"
    }

    type = "ClusterIP"

    port {
      port = 27017
      target_port = 27017
    }
  }
}

# StorageClass resource for my-storage-class
resource "kubernetes_storage_class_v1" "my_storage_class" {
  metadata {
    name = "my-storage-class"
  }

  provisioner = "kubernetes.io/gce-pd"

  parameters = {
    type = "pd-standard"
  }
}

# PersistentVolume resource for mongodb-pv
resource "kubernetes_persistent_volume_v1" "mongodb_pv" {
  metadata {
    name = "mongodb-pv"
  }

  spec {
    capacity {
      storage = "5Gi"
    }

    volume_mode = "Filesystem"
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "my-storage-class"

    gce_persistent_disk {
      pd_name = "mongodb-disk"
      fs_type = "ext4"
    }
  }
}

# PersistentVolumeClaim resource for mongodb-pvc
resource "kubernetes_persistent_volume_claim_v1" "mongodb_pvc" {
  metadata {
    name = "mongodb-pvc"
  }

  spec {
    resources {
      requests = {
        storage = "5Gi"
      }
    }

    volume_mode = "Filesystem"
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "my-storage-class"
  }
}
