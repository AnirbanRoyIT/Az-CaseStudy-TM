output "detailsofdeploymnt" {
  value = azurerm_storage_account.storageaccount.primary_blob_endpoint
  description = "storage account endpont URL"
}
