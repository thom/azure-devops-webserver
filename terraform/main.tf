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

# Create data sources
data "azurerm_image" "packer_image" {
  name                = var.packer_image_name
  resource_group_name = var.packer_resource_group
}

# Create resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

# Create a virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Create subnet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  tags                = var.tags
}

# Create network interface
resource "azurerm_network_interface" "main" {
  count               = var.instance_count
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create availability set
resource "azurerm_availability_set" "main" {
  name                         = "${var.prefix}-avail"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

# Create Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Create Network Security Rules
resource "azurerm_network_security_rule" "mynsgrules" {
  for_each                    = local.nsg_rules
  access                      = each.value.access
  direction                   = each.value.direction
  name                        = each.key
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_port_range      = each.value.destination_port_range
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Associate the Network Security Group with the internal subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Create load balancer
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lbe"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-http-server-probe"
  port                = 8080
}

# Create load balancer rule
resource "azurerm_lb_rule" "main" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "HTTPAccess"
  protocol                       = "TCP"
  frontend_port                  = 80
  backend_port                   = 8080
  probe_id                       = azurerm_lb_probe.main.id
  frontend_ip_configuration_name = azurerm_lb.main.frontend_ip_configuration[0].name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  ip_configuration_name   = "primary"
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
}

# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.instance_count
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = var.vm_size
  admin_username                  = var.vm_admin_username
  admin_password                  = var.vm_admin_password
  disable_password_authentication = false
  availability_set_id             = azurerm_availability_set.main.id
  computer_name                   = "${var.prefix}-vm-${count.index}"
  network_interface_ids           = [element(azurerm_network_interface.main.*.id, count.index)]
  source_image_id                 = data.azurerm_image.packer_image.id
  tags                            = var.tags

  os_disk {
    name                 = "${var.prefix}-vm-${count.index}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

# Create managed disks for VMs
resource "azurerm_managed_disk" "main" {
  count                = var.instance_count
  name                 = "${var.prefix}-disk-${count.index}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count              = var.instance_count
  virtual_machine_id = azurerm_linux_virtual_machine.main.*.id[count.index]
  managed_disk_id    = azurerm_managed_disk.main.*.id[count.index]
  # Assign unique Logical Unit Number
  lun     = 10 * count.index
  caching = "ReadWrite"
}
