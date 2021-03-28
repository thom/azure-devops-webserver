# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-udacity"
  location = "eastus"
  tags = {
    dept        = "Engineering"
    environment = "Production"
    project     = "Udacity Cloud DevOps using Microsoft Azure Nanodegree Program: Deploying a Web Server in Azure"
    createdby   = "Terraform"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-udacity"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "snet-udacity"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "pip-udacity"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-udacity"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSHInBound"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "nic-udacity"
  location                  = "eastus"
  resource_group_name       = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic-config-udacity"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}
