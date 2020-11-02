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

# default tags applied to all resources
variable "deployment_name" {
    default = "VAR_TEAM_NAME"
}

variable "project_name" {
    default = "magenta"
}

variable "location" {
    default = "WestEurope"
}