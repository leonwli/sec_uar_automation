data "azuread_application_published_app_ids" "well_known" {}
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

resource "azuread_service_principal" "msgraph" {
  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}

# Create Azure AD Application
resource "azuread_application" "sec_uar_ent_app" {
  display_name = var.uar_ent_app_name
  # Grant permission to the MSGraph Application
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
      type = "Role"
    }
  
   resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["GroupMember.Read.All"]
      type = "Role"
    }

     resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["Sites.ReadWrite.All"]
      type = "Role"
    }
  
  }
}

# Create Service Principal for the Application
resource "azuread_service_principal" "sec_uar_sp" {
  client_id = azuread_application.sec_uar_ent_app.client_id
}

# Create the Client Secret for the Service Principal
resource "azuread_service_principal_password" "sec_uar_sp_secret" {
  service_principal_id = azuread_service_principal.sec_uar_sp.id
  end_date             = "2028-03-01T00:00:00Z"
}

# Grant User.Read.All
resource "azuread_app_role_assignment" "user_read_all" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["User.Read.All"] # User.Read.All
  principal_object_id = azuread_service_principal.sec_uar_sp.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

# Grant Group.Read.All
resource "azuread_app_role_assignment" "group_read_all" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["GroupMember.Read.All"] # GroupMember.Read.All
  principal_object_id = azuread_service_principal.sec_uar_sp.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

# Grant sites.Read.All
resource "azuread_app_role_assignment" "sites_readwrite_all" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["GroupMember.Read.All"] # sites.Read.All
  principal_object_id = azuread_service_principal.sec_uar_sp.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}