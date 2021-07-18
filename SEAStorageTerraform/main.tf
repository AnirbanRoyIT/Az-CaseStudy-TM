resource "azurerm_storage_account" "storageaccount" {
  name                     = var.name
  resource_group_name      = var.rgroup
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = var.sku

}
