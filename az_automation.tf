resource "azurerm_automation_account" "automation_account" {
  name                = var.automation_account
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.function_app_managed_identity.id]
  }
}

resource "azurerm_automation_variable_string" "user_assigned_managed_identity_variable" {
  name                    = "ManagedIdentityPrincipalId"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account.name
  value                   = azurerm_user_assigned_identity.function_app_managed_identity.principal_id
}

resource "azurerm_automation_runbook" "sec_uar_ps_script" {
  name                    = var.sec_uar_ps_script_name
  location                = data.azurerm_resource_group.sec_automation_rg.location
  resource_group_name     = data.azurerm_resource_group.sec_automation_rg.name
  automation_account_name = azurerm_automation_account.automation_account.name
  runbook_type            = "PowerShell72"
  log_progress            = "true"
  log_verbose             = "true"
  content                 = file("${path.module}/../automation-scripts/dcr-assign-windows-is.ps1")
}