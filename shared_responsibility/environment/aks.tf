# https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html
resource "azurerm_kubernetes_cluster" "akstf" {
  name                = var.deployment_name
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  dns_prefix          = var.deployment_name
  kubernetes_version  = var.kubernetes_version
  node_resource_group = "${azurerm_resource_group.aksrg.name}_nodes_${azurerm_resource_group.aksrg.location}"
  # disk_encryption_set_id = azurerm_disk_encryption_set.des.id
  sku_tier            = var.aks_sku

  default_node_pool {
    name               = "default"
    node_count         = var.aks_node_count
    vm_size            = var.vm_size
    os_disk_size_gb    = 120
    max_pods           = 30
    vnet_subnet_id     = var.aks_subnet_id
    type               = "VirtualMachineScaleSets"
    node_labels = {
      pool = "default"
      environment = var.deployment_name
    }
    tags = {
      pool = "default"
      environment = var.deployment_name
    }
  }

  # azure_active_directory {
  #   managed = false
  #   #admin_group_object_ids = [ var.admin_object_id ]
  # }

  role_based_access_control {
    enabled        = true
  }

  network_profile {
      network_plugin = "azure"
      service_cidr   = "10.2.0.0/24"
      dns_service_ip = "10.2.0.10"
      docker_bridge_cidr = "172.17.0.1/16"
      network_policy = "calico"
      load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  # service_principal {
  #   client_id     = azuread_application.aks_app.application_id
  #   client_secret = random_string.aks_sp_password.result
  #   # client_id     = var.aks_client_id
  #   # client_secret = var.aks_client_secret
  # }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.workspace_id
    }

    kube_dashboard {
      enabled = false
    }
  }

  tags = {
    environment = var.deployment_name
    network = "azurecni"
    rbac = "true"
    policy = "calico"
    project = var.project_name
  }
}

output "KUBE_NAME" {
    value = var.deployment_name
}

output "KUBE_GROUP" {
    value = azurerm_resource_group.aksrg.name
}

output "NODE_GROUP" {
  value = azurerm_kubernetes_cluster.akstf.node_resource_group
}

output "ID" {
    value = azurerm_kubernetes_cluster.akstf.id
}

output "HOST" {
  value = azurerm_kubernetes_cluster.akstf.kube_config.0.host
}

output "SERVICE_PRINCIPAL_ID" {
  value = azurerm_kubernetes_cluster.akstf.identity.0.principal_id
}