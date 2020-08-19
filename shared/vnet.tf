# Configure the Azure Provider
# https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/terraform/terraform-create-k8s-cluster-with-tf-and-aks.md

# https://www.terraform.io/docs/providers/azurerm/d/virtual_network.html
resource "azurerm_virtual_network" "kubevnet" {
  name                = "${var.deployment_name}-vnet"
  address_space       = ["10.0.0.0/20"]
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name

  tags = {
    environment = var.deployment_name
    project = var.project_name
  }
}

# https://www.terraform.io/docs/providers/azurerm/d/subnet.html
resource "azurerm_subnet" "gwnet" {
  name                      = "1-subnet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefixes            = ["10.0.1.0/24"]
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}
resource "azurerm_subnet" "bastion" {
  name                      = "2-bastion"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefixes            = ["10.0.2.0/24"]
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}
resource "azurerm_subnet" "devrelease" {
  name                      = "devrelease"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefixes            = ["10.0.10.0/24"]
  virtual_network_name      = azurerm_virtual_network.kubevnet.name

  service_endpoints         = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_subnet" "devfuture" {
  name                      = "devfuture"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefixes            = ["10.0.5.0/24"]
  virtual_network_name      = azurerm_virtual_network.kubevnet.name

  service_endpoints         = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_subnet" "env3-subnet" {
  name                      = "env3-subnet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefixes            = ["10.0.9.0/24"]
  virtual_network_name      = azurerm_virtual_network.kubevnet.name

  service_endpoints         = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage"]
}

output "devrelease_subnet_id" {
    value = azurerm_subnet.devrelease.id
}

output "devfuture_subnet_id" {
    value = azurerm_subnet.devfuture.id
}