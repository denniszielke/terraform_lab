resource "azurerm_key_vault" "infravault" {
  name                        = "${var.deployment_name}-infravault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = var.tenant_id

  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  sku_name                    = "premium"

  # network_acls {
  #   default_action = "Deny"
  #   bypass         = "AzureServices"
  # }

  tags = {
    environment = var.deployment_name
  }
}

resource "azurerm_key_vault_access_policy" "deployment-user" {
  key_vault_id = azurerm_key_vault.infravault.id

  tenant_id = var.tenant_id
  object_id = var.current_user_object_id

  key_permissions = [
    "get",
    "list",
    "create"
  ]

  depends_on = [azurerm_key_vault.infravault]
}

resource "azurerm_key_vault_key" "encryption_key" {
  name         = "des-encryption-key"
  key_vault_id = azurerm_key_vault.infravault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_key_vault_access_policy.deployment-user]
}

resource "azurerm_key_vault_access_policy" "des_policy" {
  key_vault_id = azurerm_key_vault.infravault.id

  tenant_id = var.tenant_id
  object_id = azurerm_user_assigned_identity.controller_id.principal_id

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