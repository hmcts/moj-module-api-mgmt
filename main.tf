resource "azurerm_resource_group" "api-mgmt-resourcegroup" {
  name     = "core-api-mgmt-rg-${var.env}"
  location = "${var.location}"

  tags {
    environment = "${var.env}"
  }
}

data "template_file" "apimgmttemplate" {
  template = "${file("${path.module}/templates/api-management.json")}"
}

locals {
  name = "core-api-mgmt-${var.env}"
}

resource "azurerm_subnet" "api-mgmt-subnet" {
  name                 = "core-api-mgmt-subnet"
  resource_group_name  = "${azurerm_resource_group.api-mgmt-resourcegroup.name}"
  virtual_network_name = "${data.terraform_remote_state.core_infra.vnet_name}"
  address_prefix       = "10.20.1.0/24"
}

resource "azurerm_template_deployment" "api-managment" {
  template_body       = "${data.template_file.apimgmttemplate.rendered}"
  name                = "${local.name}"
  resource_group_name = "${azurerm_resource_group.api-mgmt-resourcegroup.name}"
  deployment_mode     = "Incremental"

  parameters = {
    location                           = "${var.location}"
    env                                = "${var.env}"
    platform_api_mgmt_name             = "${local.name}"
    platform_api_mgmt_subnetResourceId = "${azurerm_subnet.api-mgmt-subnet.id}"
  }
}