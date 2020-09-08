locals {
  name                  = "core-api-mgmt-${var.env}"
  platform_api_mgmt_sku = "${var.env == "prod" ? "Premium_1" : "Developer_1"}"
}

resource "azurerm_subnet" "api-mgmt-subnet" {
  name                 = "core-infra-subnet-apimgmt-${var.env}"
  resource_group_name  = var.vnet_rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [ "${cidrsubnet(var.source_range, 4, 4)}" ]

  lifecycle {
    ignore_changes = [address_prefix]
  }
}

resource "azurerm_api_management" "api-managment" {
  name                      = local.name
  location                  = var.location
  resource_group_name       = var.vnet_rg_name
  publisher_name            = var.publisher_name
  publisher_email           = var.publisher_email
  notification_sender_email = var.notification_sender_email
  virtual_network_type      = "Internal"

  virtual_network_configuration  {
    subnet_id = azurerm_subnet.api-mgmt-subnet.id
  }

  sku_name = local.platform_api_mgmt_sku
}
