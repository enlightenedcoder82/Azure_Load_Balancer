resource "azurerm_resource_group" "Romulus" {
  name     = "Romulus"
  location = "westus3"
  tags = {
    "Terraform" = "Terraform"
  }

}
