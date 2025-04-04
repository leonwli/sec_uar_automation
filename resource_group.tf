resource "azurerm_resource_group" "sec_automation_rg" {
  name     = var.resource_group_name
  location = var.location
}