resource "azurerm_storage_container" "scripts_blob_container" {
  name                  = var.storage_container_scripts
  storage_account_id    = data.azurerm_storage_account.storage_account_function_app.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "script_files" {
  for_each               = fileset("${path.module}/../scripts", "*")
  name                   = each.value
  storage_account_name   = data.azurerm_storage_account.storage_account_function_app.name
  storage_container_name = azurerm_storage_container.scripts_blob_container.name
  type                   = "Block"
  content_md5            = md5(file("${path.module}/../scripts/${each.value}"))
  source_content         = file("${path.module}/../scripts/${each.value}")
}
