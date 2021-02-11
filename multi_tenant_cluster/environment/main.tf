provider "azurerm" {
    subscription_id = var.subscription_id
    # client_id       = var.terraform_client_id
    # client_secret   = var.terraform_client_secret
    tenant_id       = var.tenant_id
    version = "=2.43.0"
    features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "VAR_KUBE_RG"
    storage_account_name = "VAR_TERRAFORM_NAME"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

# # Locals block for hardcoded names. 
locals {
    aks_name                       = "${var.deployment_name}-aks"
    aks_nodepool_1_name            = "agentpool"
    aks_node_rg_name               = "${var.deployment_name}_nodes_${var.location}"

    logs_name                      = "${var.deployment_name}-law"

    acr_name                       = "${var.deployment_name}acr"

    app_gateway_pip_name           = "${var.deployment_name}-appgw-pip"
    app_gateway_name               = "${var.deployment_name}-appgw"

    backend_address_pool_name      = "${var.deployment_name}-beap"
    frontend_port_name             = "${var.deployment_name}-feport"
    frontend_ip_configuration_name = "${var.deployment_name}-feip"
    http_setting_name              = "${var.deployment_name}-be-htst"
    listener_name                  = "${var.deployment_name}-httplstn"
    request_routing_rule_name      = "${var.deployment_name}-rqrt"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags       = var.tags
}







