data "azurerm_automation_account" "existing" {
  name                = var.automation_account
  resource_group_name = var.resource_group
}

resource "azurerm_automation_certificate" "sp_cert" {
  name                    = "cert-${var.connection_name}"
  resource_group_name     = var.resource_group
  automation_account_name = data.azurerm_automation_account.existing.name
  base64                  = filebase64(var.pfx_path)
  description             = "Service Principal Certificate"
  exportable              = false
  thumbprint              = "" # Optional: can be left empty if unknown
}

resource "azurerm_automation_connection" "sp_connection" {
  name                    = var.connection_name
  resource_group_name     = var.resource_group
  automation_account_name = data.azurerm_automation_account.existing.name
  type                    = "AzureServicePrincipal"
  values = {
    "ApplicationId" : azuread_application.sec_uar_ent_app.client_id,
    "TenantId" : vdata.azurerm_client_config.sec_automation_rg.tenant_id,
    "SubscriptionId" : data.azurerm_client_config.sec_automation_rg.subscription_id,
    "CertificateThumbprint" : azurerm_automation_certificate.sp_cert.thumbprint,
  }

}

resource "azurerm_automation_module" "graph_applications" {
  name                    = "Microsoft.Graph.Applications"
  resource_group_name     = var.resource_group
  automation_account_name = data.azurerm_automation_account.existing.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Applications"
  }
}

resource "azurerm_automation_module" "graph_sites" {
  name                    = "Microsoft.Graph.Sites"
  resource_group_name     = var.resource_group
  automation_account_name = data.azurerm_automation_account.existing.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Sites"
  }
}

resource "azurerm_automation_runbook" "export_assignments" {
  name                    = var.runbook_name
  location                = var.location
  resource_group_name     = var.resource_group
  automation_account_name = data.azurerm_automation_account.existing.name
  log_verbose             = true
  log_progress            = true
  description             = "Export app assignments and upload to SharePoint"
  runbook_type            = "PowerShell"
  content                 = file(var.runbook_script_path)
}
