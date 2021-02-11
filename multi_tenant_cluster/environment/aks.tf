# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
resource "azurerm_kubernetes_cluster" "aks" {
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count, role_based_access_control
    ]
  }

  name                = local.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  node_resource_group = local.aks_node_rg_name
  dns_prefix          = local.aks_name
  kubernetes_version  = var.aks_kubernetes_version
  sku_tier            = var.aks_sku
  linux_profile {
    admin_username    = var.aks_configuration["vm_user_name"]

    ssh_key {
      key_data = file(var.public_ssh_key_path)
    }
  }

  default_node_pool {
    name                = local.aks_nodepool_1_name
    vm_size             = var.aks_configuration["nodepool_1_vm_size"]
    enable_auto_scaling = true
    min_count           = var.aks_configuration["nodepool_1_min"]
    max_count           = var.aks_configuration["nodepool_1_max"]
    node_count          = var.aks_configuration["nodepool_1_size"]
    os_disk_size_gb     = var.aks_configuration["nodepool_1_disk"]
    vnet_subnet_id      = var.aks_subnet_id
    type                = "VirtualMachineScaleSets"
    #availability_zones = var.aks_zones
  }

  disk_encryption_set_id = azurerm_disk_encryption_set.des.id

  identity {
    type = "SystemAssigned"
    #user_assigned_identity_id = azurerm_user_assigned_identity.controller_id.id
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      managed = true
      admin_group_object_ids = [
        var.aks_admin_object_id
      ]
    }
  }

  network_profile {
    network_plugin     = "kubenet"
    network_policy     = "calico"
    dns_service_ip     = var.aks_configuration["dns_service_ip"]
    docker_bridge_cidr = var.aks_configuration["docker_bridge_cidr"]
    service_cidr       = var.aks_configuration["service_cidr"]
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.law_aks_logs.id
    }

    kube_dashboard {
      enabled = false
    }

    azure_policy {
      enabled = false #true
    }
  }

  # depends_on = [azurerm_virtual_network.vnet]
  tags       = var.tags
}

output "KUBE_NAME" {
    value = azurerm_kubernetes_cluster.aks.name
}

output "KUBE_GROUP" {
    value = azurerm_resource_group.rg.name
}

output "NODE_GROUP" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}