
variable "env_name" {
    default = ""
}

variable "subscription_id" {
    default = ""
}

variable "tenant_id" {
    default = ""
}

variable "resource_group_name" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "northeurope"
}

variable "deployment_name"  {
  description = "The Azure Region in which all resources in this example should be created."
  default = "app1"
}

variable "network_configuration" {
  type = map(string)
  default = {
    "vnet_address_space" = "15.0.0.0/16"
    "appgw_address_space" = "15.0.1.0/24"
    "aks_address_space" = "15.0.2.0/24"
    "bastion_address_space" = "15.0.3.0/24"    
  }
}

variable "aks_node_count" {
    default = 1
}

variable "aks_sku" {
    default = "Free"
}

variable "aks_kubernetes_version" {
    default = "1.18.14"
}

variable "aks_admin_object_id" {
    default = ""
}

variable "gw_subnet_id" {

    default = "gwsubnetid"
}

variable "aks_subnet_id" {

    default = "aks_subnet_id"
}

variable "aks_configuration" {
  type = map(string)
  default = {
    "dns" = "15.0.0.0/20"
    "vm_user_name" = "ubuntu"
    "service_cidr" = "11.0.0.0/16"
    "dns_service_ip" = "11.0.0.10"
    "docker_bridge_cidr" = "172.17.0.1/16"
    "nodepool_1_vm_size" = "Standard_E2s_v3"
    "nodepool_1_size" = 3
    "nodepool_1_min" = 3
    "nodepool_1_max" = 10
    "nodepool_1_disk" = 500
  }
}

variable "appgw_configuration" {
  type = map(string)
  default = {
    "sku" = "WAF_V2"
    "tier" = "WAF_V2"
    "capacity" = 2
  }
}

variable "public_ssh_key_path" {
  description = "Public key path for SSH."
  default     = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  type = map

  default = {
    app = "demo1",
    env = "ddd"
  }
}
