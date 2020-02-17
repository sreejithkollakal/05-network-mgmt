variable "vnet2_dbsubnet_address_space" {
  type = "string"
  default = "10.0.0.40/29"
}

variable "vnet2_appsubnet_address_space" {
  type = "string"
  default = "10.0.0.48/29"
}

variable "vnet2_gatewaysubnet_address_space" {
  type = "string"
  default = "10.0.0.56/29"
}

resource "azurerm_resource_group" "rg1" {
  name     = "terra-rg4"
  location = "South India"
}

resource "azurerm_virtual_network" "vnet1" {
    name = "terra-vnet1"
    location = "southindia"
    resource_group_name = "terra-rg4"
    address_space = ["10.0.0.0/27"]
    subnet {
        name = "appsubnet"
        address_prefix = "10.0.0.0/29"
    }
    subnet {
        name = "dbsubnet"
        address_prefix = "10.0.0.8/29"
    }
}

resource "azurerm_virtual_network" "vnet2" {
    name = "terra-vnet2"
    location = "centralindia"
    resource_group_name = "terra-rg4"
    address_space = ["10.0.0.32/27"]
    subnet {
        name = "mgmtsubnet"
        address_prefix = "10.0.0.32/29"
    }
    subnet {
        name = "dbsubnet"
        address_prefix = var.vnet2_dbsubnet_address_space
    }
    subnet {
        name = "appsubnet"
        address_prefix = var.vnet2_appsubnet_address_space
    }
    subnet {
        name = "GatewaySubnet"
        address_prefix = var.vnet2_gatewaysubnet_address_space
    }
}

resource "azurerm_subnet" "vnet1app"{
    name = "appsubnet"
    resource_group_name = "${azurerm_virtual_network.vnet1.resource_group_name}"
    virtual_network_name = "${azurerm_virtual_network.vnet1.name}"
    address_prefix = "10.0.0.0/29"
}

resource "azurerm_network_interface" "nic1" {
    name = "vnet1-app-nic1"
    resource_group_name = "${azurerm_virtual_network.vnet1.resource_group_name}"
    location = "${azurerm_virtual_network.vnet1.location}"
    #resource_group_name = "terra-rg2"
    #location = "southindia"
    ip_configuration {
        name = "ipconfig1"
        #subnet_id = "/subscriptions/c6958377-ba0d-4774-af8c-e1514fa52fdf/resourceGroups/terra-rg2/providers/Microsoft.Network/virtualNetworks/terra-vnet1/subnets/appsubnet"
        subnet_id = "${azurerm_subnet.vnet1app.id}"
        private_ip_address_allocation = "Static"
        private_ip_address = "10.0.0.4"
    }
}

resource "azurerm_network_interface" "nic2" {
    name = "vnet1-app-nic2"
    resource_group_name = "${azurerm_virtual_network.vnet1.resource_group_name}"
    location = "${azurerm_virtual_network.vnet1.location}"
    #resource_group_name = "terra-rg2"
    #location = "southindia"
    ip_configuration {
        name = "ipconfig1"
        #subnet_id = "/subscriptions/c6958377-ba0d-4774-af8c-e1514fa52fdf/resourceGroups/terra-rg2/providers/Microsoft.Network/virtualNetworks/terra-vnet1/subnets/appsubnet"
        subnet_id = "${azurerm_subnet.vnet1app.id}"
        private_ip_address_allocation = "Static"
        private_ip_address = "10.0.0.5"
    }
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "terra-nsg1"
  location            = "${azurerm_resource_group.rg1.location}"
  resource_group_name = "${azurerm_resource_group.rg1.name}"

  security_rule {
    name                       = "Inbound_Allow_3389"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }
  depends_on = [azurerm_resource_group.rg1]
}
