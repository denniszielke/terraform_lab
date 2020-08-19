resource "azurerm_key_vault" "infravault" {
  name                        = "${var.deployment_name}-infravault"
  location                    = azurerm_resource_group.aksrg.location
  resource_group_name         = azurerm_resource_group.aksrg.name
  tenant_id                   = var.tenant_id

  enabled_for_disk_encryption = true
  soft_delete_enabled         = true
  purge_protection_enabled    = true
  sku_name                    = "premium"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = {
    environment = var.deployment_name
    project = var.project_name
  }
}

output "infravault_id" {
    value = azurerm_key_vault.infravault.id
}