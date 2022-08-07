
data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = azurerm_resource_group.main.name
}
