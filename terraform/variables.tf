variable "location" {
  type        = string
  description = "The Azure Region in which all resources should be created."
  default     = "East US"
}

variable "prefix" {
  type        = string
  description = "The prefix which should be used for all resources"
  default     = "udacity-web-server"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default = {
    dept        = "Engineering"
    environment = "Production"
    project     = "Udacity Cloud DevOps using Microsoft Azure Nanodegree Program: Deploying a Web Server in Azure"
    createdby   = "Terraform"
  }
}

variable "packer_resource_group" {
  type        = string
  description = "Name of the Packer image resource group"
  default     = "udacity-web-server-rg-packer"
}

variable "packer_image_name" {
  type        = string
  description = "Name of the Packer image"
  default     = "udacity-web-server-image-ubuntu-nginx"
}

variable "instance_count" {
  type        = number
  description = "Number VM instances to create"
  default     = 2
}

variable "vm_size" {
  type        = string
  description = "Size of the virtual machine"
  default     = "Standard_B1ls"
}

variable "vm_admin_username" {
  type        = string
  description = "Administrator user name for virtual machine"
}

variable "vm_admin_password" {
  type        = string
  description = "Password must meet Azure complexity requirements"
}

locals {
  nsg_rules = {
    allow_vnet_inbound = {
      access                     = "Allow"
      direction                  = "Inbound"
      name                       = "AllowVnetInBound"
      description                = "Allow access to other VMs on the subnet"
      priority                   = 200
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }

    deny_internet_inbound = {
      access                     = "Deny"
      direction                  = "Inbound"
      name                       = "DenyInternetInBound"
      description                = "Deny direct access from the internet"
      priority                   = 100
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
    }
  }
}
