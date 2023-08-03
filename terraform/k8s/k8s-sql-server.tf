# StatefulSet resource for SQL Server
resource "kubernetes_stateful_set_v1" "sql_server" {
  metadata {
    name = "sql-server"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "sql-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "sql-server"
        }
      }

      spec {
        termination_grace_period_seconds = 10

        container {
          name  = "sql-server"
          image = "mcr.microsoft.com/mssql/server:2022-latest"
          ports {
            container_port = 1433
          }

          env {
            name  = "ACCEPT_EULA"
            value = "Y"
          }
          env {
            name = "MSSQL_SA_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.sql_server_password.metadata.0.name
                key  = "password"
              }
            }
          }

          volume_mount {
            name       = "sql-server-volume"
            mount_path = "/var/opt/mssql"
          }
        }

        volume {
          name = "sql-server-volume"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.sql_server_pvc.metadata.0.name
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "sql-server-pvc"
      }

      spec {
        access_modes      = ["ReadWriteOnce"]
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

# Service resource for SQL Server
resource "kubernetes_service_v1" "sql_server" {
  metadata {
    name = "sql-server"
  }

  spec {
    selector = {
      app = "sql-server"
    }

    type = "ClusterIP"

    port {
      port = 1433
      target_port = 1433
    }
  }
}

# Secret resource for SQL Server password
resource "kubernetes_secret_v1" "sql_server_password" {
  metadata {
    name = "sql-server-password"
  }

  type = "Opaque"

  data = {
    password = "<base64-encoded-password>"
  }
}

# PersistentVolume resource for sql-server-pv
resource "kubernetes_persistent_volume_v1" "sql_server_pv" {
  metadata {
    name = "sql-server-pv"
  }

  spec {
    capacity {
      storage = "5Gi"
    }

    volume_mode = "Filesystem"
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "my-storage-class"

    gce_persistent_disk {
      pd_name = "sql-server-disk"
      fs_type = "ext4"
    }
  }
}