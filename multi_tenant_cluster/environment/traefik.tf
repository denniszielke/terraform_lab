# Create Static Public IP Address to be used by Traefik Ingress
resource "azurerm_public_ip" "traefik_ingress" {
  name                         = "traefik-ingress-pip"
  location                     = azurerm_kubernetes_cluster.aks.location
  resource_group_name          = azurerm_kubernetes_cluster.aks.node_resource_group
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = local.traefik_dns_name

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Install traefik Ingress using Helm Chart
# https://github.com/helm/charts/tree/master/stable/traefik
# https://www.terraform.io/docs/providers/helm/release.html
resource "helm_release" "traefik_ingress" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik" 
  chart      = "traefik"
  namespace  = "kube-system"
  force_update = "true"
  timeout = "500"

  set {
    name  = "replicas"
    value = "2"
  }

  set {
    name  = "externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "loadBalancerIP"
    value = azurerm_public_ip.traefik_ingress.ip_address
  }
  
  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_public_ip.traefik_ingress, null_resource.after_charts]
}