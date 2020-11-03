
resource "kubernetes_namespace" "demo-ns" {
  metadata {
    name = "demo"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment
resource "kubernetes_deployment" "demo-app" {
  metadata {
    name = "demo-app"
    namespace = kubernetes_namespace.demo-ns.name
    labels = {
      app = "dummy-logger"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "dummy-logger"
      }
    }

    template {
      metadata {
        labels = {
          app = "dummy-logger"
        }
      }

      spec {
        container {
          image = "denniszielke/dummy-logger:latest"
          name  = "dummy-logger"

          resources {
            requests {
              cpu    = "100m"
              memory = "56Mi"
            }
            limits {
              cpu    = "200m"
              memory = "300Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = 80
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.demo-ns]
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service
resource "kubernetes_service" "demo-svc" {
  metadata {
    name = "dummy-svc"
    namespace = kubernetes_namespace.demo-ns.name
  }
  spec {
    selector = {
      app = "dummy-logger"
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
  
  depends_on = [kubernetes_namespace.demo-ns]
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress
resource "kubernetes_ingress" "appgw-ingress" {
  metadata {
    name = "appgw-ingress"
    namespace = kubernetes_namespace.demo-ns.name
    annotations = {
      "kubernetes.io/ingress.class" = "azure/application-gateway"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = "dummy-svc"
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.demo-ns]
}


# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress
resource "kubernetes_ingress" "traefik-ingress" {
  metadata {
    name = "traefik-ingress"
    namespace = kubernetes_namespace.demo-ns.name
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
    }
  }

  spec {

    rule {
      host = "${azurerm_public_ip.traefik_ingress.ip_address}.xip.io"
      http {
        path {
          backend {
            service_name = "dummy-svc"
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.demo-ns]
}

output "TRAEFIK_INGRESS" {
  value = "http://${azurerm_public_ip.traefik_ingress.ip_address}.xip.io/ping"
}

output "APPGW_INGRESS" {
  value = "http://${azurerm_public_ip.pip_appgw.ip_address}.xip.io/ping"
}