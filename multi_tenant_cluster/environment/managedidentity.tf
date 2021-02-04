resource "azurerm_user_assigned_identity" "controller_id" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  name = local.aks_name
}