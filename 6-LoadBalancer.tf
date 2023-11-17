resource "azurerm_public_ip" "Romulus_PublicIP" {
  name                = "Romulus_PublicIP"
  location            = azurerm_resource_group.Romulus.location
  resource_group_name = azurerm_resource_group.Romulus.name
  allocation_method   = "Static"
}

#Create Load Balancer
resource "azurerm_lb" "Romulus_LB01" {
  name                = "Romulus_LB01"
  location            = azurerm_resource_group.Romulus.location
  resource_group_name = azurerm_resource_group.Romulus.name

  frontend_ip_configuration {
    name                          = "Romulus_FrontEndIP"
    subnet_id                     = azurerm_subnet.PublicA.id
    public_ip_address_id          = azurerm_public_ip.Romulus_PublicIP.id        
  
                     
  }
}

  
  resource "azurerm_lb_backend_address_pool" "Romulus_BackEndPool" {
    loadbalancer_id = azurerm_lb.Romulus_LB01.id
    name            = "Romulus_BackEndPool"
  #   backend_ip_configurations = "NIC"

  }

  resource "azurerm_lb_probe" "Romulus-inbound-probe" {
  resource_group_name = azurerm_resource_group.Romulus.name
  loadbalancer_id     = azurerm_lb.Romulus_LB01.id
  name                = "HTTP-inbound-probe"
  port                = 80
  }

  resource "azurerm_lb_rule" "Romulus-inbound-rules" {
  loadbalancer_id                = azurerm_lb.Romulus_LB01.id
  resource_group_name            = azurerm_resource_group.Romulus.name
  name                           = "HTTP-inbound-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "Romulus_FrontEndIP"
  probe_id                       = azurerm_lb_probe.Romulus-inbound-probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.Romulus_BackEndPool.id

  }

  resource "azurerm_lb_nat_rule" "Romulus_Rule" {
  resource_group_name            = azurerm_resource_group.Romulus.name
  loadbalancer_id                = azurerm_lb.Romulus_LB01.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 50000
  backend_port                   = 3389
  frontend_ip_configuration_name = "Romulus_FrontEndIP"
  idle_timeout_in_minutes        = 4
}

resource "azurerm_lb_nat_pool" "Romulus_NAT_Pool" {
  resource_group_name            = azurerm_resource_group.Romulus.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.Romulus_LB01.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "Romulus_FrontEndIP"
}

