provider "azurerm" {
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
    features {}
}

# https://www.terraform.io/docs/providers/azurerm/d/resource_group.html
resource "azurerm_resource_group" "aksrg" {
  name     = var.deployment_name
  location = var.location
    
  tags = {
    environment = var.deployment_name
    project = var.project_name
  }
}