resource "azurerm_key_vault" "applicationvault" {
  name                        = "${var.deployment_name}-vault"
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

# resource "azurerm_key_vault_key" "encryption_key" {
#   name         = "des-encryption-key"
#   key_vault_id = var.infravault_id
#   key_type     = "RSA"
#   key_size     = 2048

#   key_opts = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "unwrapKey",
#     "verify",
#     "wrapKey",
#   ]
# }

# resource "azurerm_disk_encryption_set" "des" {
#   name                        = "des"
#   location                    = azurerm_resource_group.aksrg.location
#   resource_group_name         = var.shared_rg_name
#   key_vault_key_id            = var.infravault_id

#   identity {
#     type = "SystemAssigned"
#   }

  # tags = {
  #   environment = var.deployment_name
  #   project = var.project_name
  # }
# }

# resource "azurerm_key_vault_access_policy" "des_policy" {
#   key_vault_id = var.infravault_id

#   tenant_id = var.tenant_id
#   object_id = azurerm_kubernetes_cluster.akstf.identity.0.principal_id

#   key_permissions = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "unwrapKey",
#     "verify",
#     "wrapKey",
#   ]
# }

# resource "azurerm_key_vault_access_policy" "deployment-user" {
#   key_vault_id = azurerm_key_vault.aksvault.id

#   tenant_id = var.tenant_id
#   object_id = data.azurerm_client_config.current.object_id

#   key_permissions = [
#     "get",
#     "create"
#   ]
# }