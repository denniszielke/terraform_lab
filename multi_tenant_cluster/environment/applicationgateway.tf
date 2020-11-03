# Public Ip for appgateway
resource "azurerm_public_ip" "pip_appgw" {
  name                         = local.app_gateway_pip_name
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  allocation_method            = "Static"
  sku                          = "Standard"

  tags = var.tags
}

# https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html
resource "azurerm_application_gateway" "appgw" {
  name                = local.app_gateway_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = var.appgw_configuration["sku"]
    tier     = var.appgw_configuration["tier"]
    capacity = var.appgw_configuration["capacity"]
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.subnet_appgw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip_appgw.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  tags = var.tags

  depends_on = [azurerm_virtual_network.vnet, azurerm_subnet.subnet_appgw ,azurerm_public_ip.pip_appgw]
}

output "APPGW_PUBLIC_IP" {
  value = azurerm_public_ip.pip_appgw.ip_address
}