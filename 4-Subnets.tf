resource "azurerm_subnet" "PublicA" {
  name                 = "PublicA"
  resource_group_name  = azurerm_resource_group.Romulus.name
  virtual_network_name = azurerm_virtual_network.Romulus-Vnet.name
  address_prefixes     = ["10.202.1.0/24"]


  delegation {
    name = "PublicA"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "PublicB" {
  name                 = "PublicB"
  resource_group_name  = azurerm_resource_group.Romulus.name
  virtual_network_name = azurerm_virtual_network.Romulus-Vnet.name
  address_prefixes     = ["10.202.2.0/24"]

  delegation {
    name = "PublicB"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet_nat_gateway_association" "PublicA-NAT" {
  subnet_id      = azurerm_subnet.PublicA.id
  nat_gateway_id = azurerm_nat_gateway.Romulus-NAT.id
}

resource "azurerm_subnet_network_security_group_association" "PublicA-NSG" {
  subnet_id                 = azurerm_subnet.PublicA.id
  network_security_group_id = azurerm_network_security_group.Romulus-NSG.id
}

resource "azurerm_subnet_network_security_group_association" "PublicB-NSG" {
  subnet_id                 = azurerm_subnet.PublicB.id
  network_security_group_id = azurerm_network_security_group.Romulus-NSG.id
}




resource "azurerm_network_interface" "Romulus_nic01" {
  name                = "Romulus_nic01"
  location            = azurerm_resource_group.Romulus.location
  resource_group_name = azurerm_resource_group.Romulus.name

  ip_configuration {
    name                          = "internal-01"
    subnet_id                     = azurerm_subnet.PublicA.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "Romulus_nic02" {
  name                = "Romulus_nic02"
  location            = azurerm_resource_group.Romulus.location
  resource_group_name = azurerm_resource_group.Romulus.name

  ip_configuration {
    name                          = "internal-02"
    subnet_id                     = azurerm_subnet.PublicB.id
    private_ip_address_allocation = "Dynamic"
  }
}

 resource "azurerm_network_interface_backend_address_pool_association" "Romulus-nic-assoc1" {
  network_interface_id    = azurerm_network_interface.Romulus_nic01.id
  ip_configuration_name   = "internal-01"
  backend_address_pool_id = azurerm_lb_backend_address_pool.Romulus_BackEndPool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "Romulus-nic-assoc2" {
  network_interface_id    = azurerm_network_interface.Romulus_nic02.id
  ip_configuration_name   = "internal-02"
  backend_address_pool_id = azurerm_lb_backend_address_pool.Romulus_BackEndPool.id

  

}
