resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.network_configuration["vnet_address_space"]]
  tags = var.tags
}

resource "azurerm_subnet" "subnet_appgw" {
  name                 = local.subnet_appgw_name
  address_prefixes     = [var.network_configuration["appgw_address_space"]]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "subnet_aks" {
  name                 = local.subnet_aks_name
  address_prefixes     = [var.network_configuration["aks_address_space"]]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "subnet_bastion" {
  name                 = "AzureBastionSubnet"
  address_prefixes     = [var.network_configuration["bastion_address_space"]]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}


resource "azurerm_role_assignment" "aks_subnet" {
  scope                = azurerm_subnet.subnet_aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}