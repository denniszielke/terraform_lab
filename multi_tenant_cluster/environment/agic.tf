resource "azurerm_user_assigned_identity" "agicidentity" {
  name = "${var.deployment_name}-agic-id"
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  location            = azurerm_resource_group.rg.location
  tags = var.tags
}

resource "azurerm_role_assignment" "agicidentityappgw" {
  scope                = azurerm_application_gateway.appgw.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.agicidentity.principal_id
}

resource "azurerm_role_assignment" "agicidentityappgwgroup" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.agicidentity.principal_id
}


resource "azurerm_role_assignment" "podidentitykubeletoperator" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_kubernetes_cluster.aks.node_resource_group}"
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}
# try if can be removed
resource "azurerm_role_assignment" "agicoperator" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_kubernetes_cluster.aks.node_resource_group}"
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.agicidentity.principal_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "azurerm_role_assignment" "contolleroperator" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_kubernetes_cluster.aks.node_resource_group}"
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.identity.0.principal_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# https://www.terraform.io/docs/providers/helm/release.html
resource "helm_release" "ingress-azure" {
  name       = "ingress-azure"
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/" 
  chart      = "ingress-azure"
  namespace  = "kube-system"
  force_update = "true"
  timeout = "500"

  set {
    name  = "appgw.name"
    value = azurerm_application_gateway.appgw.name
  }

  set {
    name  = "appgw.resourceGroup"
    value = azurerm_resource_group.rg.name
  }

  set {
    name  = "appgw.subscriptionId"
    value = var.subscription_id
  }

  set {
    name  = "appgw.usePrivateIP"
    value = false
  }

  set {
    name  = "appgw.shared"
    value = false
  }

  set {
    name  = "armAuth.type"
    value = "aadPodIdentity"
  }

  set {
    name  = "armAuth.identityClientID"
    value = azurerm_user_assigned_identity.agicidentity.client_id
  }

  set {
    name  = "armAuth.identityResourceID"
    value = azurerm_user_assigned_identity.agicidentity.id
  }

  set {
    name  = "rbac.enabled"
    value = "true"
  }

  depends_on = [azurerm_kubernetes_cluster.aks, null_resource.after_charts, helm_release.aad-pod-identity]
}