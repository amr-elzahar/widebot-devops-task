# Deployment resource
resource "kubernetes_deployment_v1" "app" {
  metadata {
    name = "app"
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "app"
      }
    }

    template {
      metadata {
        labels = {
          app = "app"
        }
      }

      spec {
        container {
          name  = "app"
          image = "amrelzahar/aspnet-mssql-web:latest"
          ports {
            container_port = 80
          }

          env_from {
              name = kubernetes_config_map.domain_name_configmap.metadata.0.name
            }
            config_map_ref {
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.ssl_secret.metadata.0.name
            }
          }
        }
      }
    }
  }
}

# Service resource
resource "kubernetes_service_v1" "web_app_service" {
  metadata {
    name = "web-app-service"
  }

  spec {
    selector = {
      app = "app"
    }

    type = "LoadBalancer"

    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = 80
    }
  }
}

# Ingress resource
resource "kubernetes_ingress_v1" "ingress_app" {
  metadata {
    name = "ingress-app"
  }

  spec {
    tls {
      secret_name = kubernetes_secret.ssl_secret.metadata.0.name
      hosts       = ["my-domain.com"]
    }

    rule {
      http {
        path {
          path_type = "Prefix"
          path      = "/"
        }

        backend {
          service_name = kubernetes_service.web_app_service.metadata.0.name
          service_port = 443
        }
      }
    }
  }
}

# ConfigMap resource
resource "kubernetes_config_map_v1" "domain_name_configmap" {
  metadata {
    name = "domain-name-configmap"
  }

  data = {
    DOMAIN_NAME = "my-domain.com"
  }
}

# Secret resource
resource "kubernetes_secret_v1" "ssl_secret" {
  metadata {
    name = "ssl-secret"
  }

  type = "Opaque"

  data = {
    ssl_certificate = "<BASE64_ENCODED_CERTIFICATE>"
    ssl_private_key = "<BASE64_ENCODED_PRIVATE_KEY>"
  }
}
