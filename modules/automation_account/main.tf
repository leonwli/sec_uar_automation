# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
resource "azurerm_automation_account" "automation_account" {
  name                = var.automation_account
  location            = data.azurerm_resource_group.security_rg.location
  resource_group_name = data.azurerm_resource_group.security_rg.name
  sku_name            = "Basic"
  identity {
    type         = "SystemAssigned, UserAssigned"
  }
}