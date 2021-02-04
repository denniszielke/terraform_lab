
resource "azurerm_disk_encryption_set" "des" {
  name                        = "des"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  key_vault_key_id            = azurerm_key_vault_key.encryption_key.id

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.deployment_name
  }

  depends_on = [azurerm_key_vault_key.encryption_key]
}

resource "azurerm_key_vault_access_policy" "des-permission" {
  key_vault_id = azurerm_key_vault.infravault.id

  tenant_id = azurerm_disk_encryption_set.des.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.des.identity.0.principal_id

  key_permissions = [
    "get",
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}