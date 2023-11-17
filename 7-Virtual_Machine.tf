resource "azurerm_virtual_machine_scale_set" "Romulus_Vmss1" {
  name                = "Romulus_Vmss1"
  location            = azurerm_resource_group.Romulus.location
  resource_group_name = azurerm_resource_group.Romulus.name

  # automatic rolling upgrade
  automatic_os_upgrade = true
  upgrade_policy_mode  = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  # required when using rolling upgrade policy
  health_probe_id = azurerm_lb_probe.Romulus-inbound-probe.id

  sku {
    name     = "Standard_F2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "testvm"
    admin_username       = "myadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/myadmin/.ssh/authorized_keys"
      key_data = file("~/.ssh/demo_key.pub")
    }
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "Romulus_IPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.PublicA.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.Romulus_BackEndPool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.Romulus_NAT_Pool.id]
    }
  }

  tags = {
    environment = "staging"
  }
}
#Romulus Usage with Unmanaged Disks


resource "azurerm_virtual_network" "Romulus_V-net" {
  name                = "acctvn"
  address_space       = ["10.202.0.0/16"]
  location            = azurerm_resource_group.Romulus.location
  resource_group_name = azurerm_resource_group.Romulus.name
}



resource "azurerm_storage_account" "Romulus_Account" {
  name                     = "accsa"
  resource_group_name      = azurerm_resource_group.Romulus.name
  location                 = azurerm_resource_group.Romulus.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "Romulus_Container" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.Romulus_Account.name
  container_access_type = "private"
}

resource "azurerm_virtual_machine_scale_set" "Romulus_Vmss2" {
  name                = "mytestscaleset-2"
  location            = azurerm_resource_group.Romulus.location
  resource_group_name = azurerm_resource_group.Romulus.name
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_F2"
    tier     = "Standard"
    capacity = 2
  }

  os_profile {
    computer_name_prefix = "testvm"
    admin_username       = "myadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/myadmin/.ssh/authorized_keys"
      key_data = file("~/.ssh/demo_key.pub")
    }
  }

  network_profile {
    name    = "TestNetworkProfile"
    primary = true

    ip_configuration {
      name      = "TestIPConfiguration"
      primary   = true
      subnet_id = azurerm_subnet.PublicA.id
    }
  }

  storage_profile_os_disk {
    name           = "osDiskProfile"
    caching        = "ReadWrite"
    create_option  = "FromImage"
    vhd_containers = ["${azurerm_storage_account.Romulus_Account.primary_blob_endpoint}${azurerm_storage_container.Romulus_Container.name}"]
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
