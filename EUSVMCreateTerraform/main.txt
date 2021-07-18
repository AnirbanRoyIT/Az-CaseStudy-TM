resource "azurerm_resource_group" "rg" {
  name = "EUS-RG"
  location = var.region
}

resource "azurerm_virtual_network" "rg" {
   name                = "Branch_Vnet"
   address_space       = ["10.20.0.0/16"]
   location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "rg" {
   name                 = "Brunch_Subnet"
   resource_group_name  = azurerm_resource_group.rg.name
   virtual_network_name = azurerm_virtual_network.rg.name
   address_prefixes     = ["10.20.1.0/24"]
}
resource "azurerm_public_ip" "pubip" {
  name                = "branchpub-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "rg" {
   name                = "BranchVm-NIC"
   location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
ip_configuration {
     name                          = "internal"
     subnet_id                     = azurerm_subnet.rg.id
     private_ip_address_allocation = "Dynamic"
     public_ip_address_id          = azurerm_public_ip.pubip.id
   }
 }
 resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "BranchNsg"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "PortRule"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "10.20.1.0/24"
    }
}

resource "azurerm_network_interface_security_group_association" "nsg-nic" {
  network_interface_id      = azurerm_network_interface.rg.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

resource "azurerm_windows_virtual_machine" "winvm" {
    name                  = "Server11"
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.rg.id]
    size                  = "Standard_D2s_v3"

    os_disk {
        name              = "OsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
    }

    computer_name  = "Server11"
    admin_username = "vmadmin"
    admin_password = "Password@12345"

}
