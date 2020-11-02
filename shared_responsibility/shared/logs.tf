# https://www.terraform.io/docs/providers/azurerm/d/log_analytics_workspace.html
resource "azurerm_log_analytics_workspace" "akslogs" {
  name                = "${var.deployment_name}-laspace"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  sku                 = "PerGB2018"

  tags = {
    environment = var.deployment_name
    project = var.project_name
  }
}

resource "azurerm_log_analytics_solution" "akslogs" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.aksrg.location
  resource_group_name   = azurerm_resource_group.aksrg.name
  workspace_resource_id = azurerm_log_analytics_workspace.akslogs.id
  workspace_name        = azurerm_log_analytics_workspace.akslogs.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

output "workspace_id" {
    value = azurerm_log_analytics_workspace.akslogs.id
}

output "workspace_name" {
    value = azurerm_log_analytics_workspace.akslogs.name
}