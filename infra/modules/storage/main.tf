resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
  allow_nested_items_to_be_public = var.allow_blob_public_access
  tags                     = var.tags
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.blob_containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = var.container_access_type
}
