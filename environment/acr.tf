# # https://www.terraform.io/docs/providers/azurerm/r/role_assignment.html
# resource "azurerm_role_assignment" "aksacrrole" {
#   scope                = azurerm_container_registry.aksacr.id
#   role_definition_name = "Reader"
#   principal_id         = azurerm_kubernetes_cluster.akstf.kubelet_identity.user_assigned_identity_id

#   depends_on = [azurerm_container_registry.aksacr, azurerm_kubernetes_cluster.akstf]
# }

# # https://www.terraform.io/docs/providers/azurerm/r/container_registry.html

# resource "azurerm_container_registry" "aksacr" {
#   name                     = "${var.deployment_name}acr"
#   resource_group_name      = azurerm_resource_group.aksrg.name
#   location                 = azurerm_resource_group.aksrg.location
#   sku                      = "Premium"
#   admin_enabled            = true

#   tags = {
#     environment = var.deployment_name
#     project = var.project_name
#   }
# }