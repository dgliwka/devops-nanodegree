resource "azurerm_availability_set" "main" {
  name                = "${var.project_name}-avset"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = "Production"
  }
}
