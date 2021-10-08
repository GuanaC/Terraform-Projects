provider "azurerm" {

    subscription_id = var.subscriptionID

    features {}
}

resource "azurerm_network_security_group" "DammySG" {
  name                = "GuanaNSG"
  location            = "Central US"
  resource_group_name = var.resourceGroupName
}

resource "azurerm_network_security_rule" "Port3389" { 
  name                        = "RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_network_security_group.DammySG.resource_group_name
  network_security_group_name = azurerm_network_security_group.DammySG.name
}

resource "azurerm_network_security_rule" "Port443" {
  name                        = "Allow443"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_network_security_group.DammySG.resource_group_name
  network_security_group_name = azurerm_network_security_group.DammySG.name
}

resource "azurerm_virtual_network" "dammyvnet" {
  name                = "dammy-vnet"
  location            = var.location
  resource_group_name = var.resourceGroupName
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["8.8.8.8", "8.8.4.4"]

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "dammy-sub" {
  name                 = "dammysubnet"
  resource_group_name  = azurerm_network_security_group.DammySG.resource_group_name
  virtual_network_name = azurerm_virtual_network.dammyvnet.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "dammy-publicIP" {
  name                = "guana-publicIP"
  location            = "Central US"
  resource_group_name = azurerm_network_security_group.DammySG.resource_group_name
  allocation_method   = "Static"
  ip_version          = "IPv4"
}

resource "azurerm_network_interface" "dammy-NIC" {
  name                = "guana-NIC"  
  location            = "Central US"
  resource_group_name = azurerm_network_security_group.DammySG.resource_group_name

    ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.dammy-sub.id 
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dammy-publicIP.id
  }

  tags = {
    environment = "Dev"
        }   
    }