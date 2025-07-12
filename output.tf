output "azuread_app_output" {
    value = {
      client_id = module.azure_entraid_app_registration.az_app_output.client_id
      object_id = module.azure_entraid_app_registration.az_app_output.object_id
      password = module.azure_entraid_app_registration.az_app_output.password

    }
    sensitive = true
}