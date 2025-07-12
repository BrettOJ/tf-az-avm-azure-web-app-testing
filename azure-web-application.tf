locals {
  tags = {
    environment = "test"
    owner       = "BrettOJ"
    created_by  = "Terraform"
  }
  location = "southeastasia"
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = ["boj", "webapp", "002"]
}

module "avm-res-resources-resourcegroup" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  name     = module.naming.resource_group.name
  location = local.location
  tags     = local.tags

}

module "avm-res-web-serverfarm" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "0.7.0"

  location               = local.location
  name                   = module.naming.app_service_plan.name
  os_type                = "Linux"
  resource_group_name    = module.naming.resource_group.name
  sku_name               = "F1"
  zone_balancing_enabled = false
  worker_count           = 1
  tags                   = local.tags
  depends_on             = [module.avm-res-resources-resourcegroup]
}

module "avm-res-web-site" {
  source                   = "Azure/avm-res-web-site/azurerm"
  version                  = "0.17.2"
  kind                     = "webapp"
  location                 = local.location
  name                     = "${module.naming.function_app.name}-webapp"
  os_type                  = module.avm-res-web-serverfarm.resource.os_type
  resource_group_name      = module.naming.resource_group.name
  service_plan_resource_id = module.avm-res-web-serverfarm.resource_id
  enable_telemetry         = false
  tags                     = local.tags
  site_config = {
    always_on         = false
    use_32_bit_worker = true
  }
  depends_on = [module.avm-res-resources-resourcegroup, module.avm-res-web-serverfarm]

}