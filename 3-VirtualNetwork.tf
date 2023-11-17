resource "azurerm_virtual_network" "Romulus-Vnet" {
  name                = "Romulus-Vnet"
  location            = azurerm_resource_group.Romulus.location
  resource_group_name = azurerm_resource_group.Romulus.name
  address_space       = ["10.202.0.0/16"]
  dns_servers         = ["10.202.0.4", "10.202.0.5"]

}
