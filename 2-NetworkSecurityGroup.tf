resource "azurerm_network_security_group" "Romulus-NSG" {
  name                = "Romulus_NSG"
  location            = azurerm_resource_group.Romulus.location
  resource_group_name = azurerm_resource_group.Romulus.name

  tags = {
    environment = "Network_Security_Group"
  }

  security_rule {
    name                       = "Romulus_SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "SSH"

  }

  security_rule {
    name                       = "Romulus_HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "HTTP"

  }


}
