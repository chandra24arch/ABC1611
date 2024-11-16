resource "azurerm_resource_group" "rgabc" {
  location = var.location
  name     = var.rg_name
}

resource "azurerm_virtual_network" "vnetabc1" {
  name                = "vnet1"
  resource_group_name = var.rg_name
  address_space       = var.address_space1
  location            = var.location
}

resource "azurerm_virtual_network" "network2" {
  name                = "vnet2"
  resource_group_name = var.rg_name
  address_space       = var.address_space2
  location            = var.location
}


resource "azurerm_subnet" "subnetabc" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rgabc.name
  virtual_network_name = azurerm_virtual_network.vnetabc1.name
  address_prefixes     = var.subnet_space1

	depends_on = [azurerm_resource_group.rgabc]
}


resource "azurerm_subnet" "subnetabc2" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rgabc.name
  virtual_network_name = azurerm_virtual_network.network2.name
  address_prefixes     = var.subnet_space2

        depends_on = [azurerm_resource_group.rgabc]
}


resource "azurerm_ssh_public_key" "ssh" {
  name                = var.key
  resource_group_name = azurerm_resource_group.rgabc.name
  location            = var.location
  public_key          = file("~/.ssh/id_rsa.pub")
}

resource "azurerm_public_ip" "public-ipabc" {
  name                = var.public-ip_name
  resource_group_name = azurerm_resource_group.rgabc.name
  location            = var.location
  allocation_method   = "Static"
}



resource "azurerm_network_interface" "nicvm1" {
  name                = "vmnic1"
  resource_group_name = azurerm_resource_group.rgabc.name
  location            = var.location
  ip_configuration {
    name                          = var.ip_name
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ipabc.id
    subnet_id                     = azurerm_subnet.subnetabc.id
  }
}
resource "azurerm_network_interface" "nicvm2" {
  name                = "nic-vm2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rgabc.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetabc2.id
    private_ip_address            = var.private_ip
    private_ip_address_allocation = "Static"
  }

}

resource "azurerm_linux_virtual_machine" "linux-vm1" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.rgabc.name
  location            = var.location

  admin_username        = var.admin
  network_interface_ids = [azurerm_network_interface.nicvm1.id]
  size                  = var.size
  
 admin_ssh_key {
    
    public_key = file("~/.ssh/id_rsa.pub")
    username   = var.admin
}
  
 os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
}
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rgabc.name
  size                = "Standard_B1s"
  admin_username      = var.admin
  admin_ssh_key {
    username   = var.admin
  public_key = file("~/.ssh/id_rsa.pub")
}


os_disk {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
 }
   source_image_reference {
     publisher = "Canonical"
     offer     = "0001-com-ubuntu-server-jammy"
     sku       = "22_04-lts"
     version   = "latest"
   }


network_interface_ids = [azurerm_network_interface.nicvm2.id]
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg
  location            = azurerm_resource_group.rgabc.location
  resource_group_name = azurerm_resource_group.rgabc.name

  security_rule {
    name                       = "sshport"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
security_rule {
    name                       = "icmp"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

}
}
resource "azurerm_network_interface_security_group_association" "nsgasoc" {
  network_interface_id      = azurerm_network_interface.nicvm1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_network_peering" "vnet_peering1" {
  name                           = "vnet1-to-vnet2"
  resource_group_name            = azurerm_resource_group.rgabc.name
  virtual_network_name           = azurerm_virtual_network.vnetabc1.name
  remote_virtual_network_id     = azurerm_virtual_network.network2.id
  allow_virtual_network_access  = true
  allow_forwarded_traffic       = true
  allow_gateway_transit         = false
  use_remote_gateways           = false
}

resource "azurerm_virtual_network_peering" "vnet_peering2" {
  name                           = "vnet2-to-vnet1"
  resource_group_name            = azurerm_resource_group.rgabc.name
  virtual_network_name           = azurerm_virtual_network.network2.name
  remote_virtual_network_id     = azurerm_virtual_network.vnetabc1.id
  allow_virtual_network_access  = true
  allow_forwarded_traffic       = true
  allow_gateway_transit         = false
  use_remote_gateways           = false
}
