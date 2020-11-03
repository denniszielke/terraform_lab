resource "azurerm_role_assignment" "aksacrrole" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  
  depends_on = [azurerm_container_registry.acr, azurerm_kubernetes_cluster.aks]
}

resource "azurerm_container_registry" "acr" {
  name                     = local.acr_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Premium"
  admin_enabled            = false
  tags                     = var.tags
}

output "CONTAINER_REGISTRY_URL" {
  value = azurerm_container_registry.acr.login_server
}