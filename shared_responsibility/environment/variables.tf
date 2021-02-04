# azure subscription id

# Terraform backend
terraform {
  backend "azurerm" {
    resource_group_name  = "statemagenta1westeurope"
    storage_account_name = "tmagenta1westeurope"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

variable "subscription_id" {
    default = "VAR_SUBSCRIPTION_ID"
}

# azure ad tenant id
variable "tenant_id" {
    default = "VAR_TENANT_ID"
}

# shared resource group name
variable "shared_rg_name" {
    default = ""
}

# aks subnet resource id
variable "aks_subnet_id" {
    default = ""
}

variable "aks_node_count" {
    default = 1
}

variable "aks_sku" {
    default = "Free"
}

variable admin_object_id {
    default = ""
}

# log analytics resource id
variable "workspace_id" {
    default = ""
}

variable "infravault_id" {
    default = ""
}

# default tags applied to all resources
variable "deployment_name" {
    default = "VAR_TEAM_NAME"
}

variable "project_name" {
    default = "magenta"
}

variable "vm_size" {
    default = "Standard_DS2_v2"
}

# kubernetes version
variable "kubernetes_version" {
    default = "1.18.14" #"1.17.9" # 1.17 required for disk encryption
}

variable "location" {
    default = "WestEurope"
}