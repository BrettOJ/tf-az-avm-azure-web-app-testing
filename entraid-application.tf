data "azuread_client_config" "current" {
  # This data source retrieves the current Azure AD client configuration
}

module "azure_entraid_app_registration" {
  source = "git::https://github.com/BrettOJ/tf-az-module-azuread-application?ref=main"

    display_name = "entraid-app-registration"
    feature_tags = {
      enterprise = true
      gallery    = false    
    }
    password = {
      display_name = "MySecret-1"
      start_date   = "2025-07-12T00:00:00Z"
      end_date     = "2026-07-12T00:00:00Z"
    }
    required_resource_access = [{
        resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
        resource_access = [{
            id   = "37f7f235-527c-4136-accd-4a02d197296e" # OpenID
            type = "Role"
        }]
        resource_access = [{
            id   = "14dad69e-099b-42c9-810b-d002981feec1" # profile
            type = "Role"
        }]
        resource_access = [{
            id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # email
            type = "Role"
        }]
        resource_access = [{
            id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
            type = "Role"
        }]
    }]
    web = {
    homepage_url  = "https://app.example.net"
    logout_url    = "https://app.example.net/logout"
    redirect_uris = ["https://app.example.net/account"]

    implicit_grant = {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}


resource "azuread_service_principal" "example" {
  client_id                    = module.azure_entraid_app_registration.az_app_output.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  feature_tags {
    enterprise = true
    gallery    = true
  }
  depends_on = [ module.azure_entraid_app_registration ]
}