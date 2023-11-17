resource "azurerm_nat_gateway" "Romulus-NAT" {
  name                    = "nat-Gateway"
  location                = azurerm_resource_group.Romulus.location
  resource_group_name     = azurerm_resource_group.Romulus.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}
