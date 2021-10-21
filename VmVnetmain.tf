
resource "azurerm_resource_group" "rg" {
  name = "RGSPJ"
  location = "westus2"
}

resource "azurerm_virtual_network" "vnet" {
  name = "PocVnet"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  address_space = [ "192.168.0.0/16" ]

}

resource "azurerm_subnet" "subnet"{
  name = "PocSubnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["192.168.1.0/24"]
}

resource "azurerm_public_ip" "publicip" {
  name                = "PocpublicIp1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "Pocnic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "Pocvm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "pocadin"
  admin_password      = "Wissen@1234567"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
