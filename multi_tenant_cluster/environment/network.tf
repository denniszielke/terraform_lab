
resource "azurerm_role_assignment" "aks_subnet" {
  scope                = var.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.controller_id.principal_id
}