resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "${var.project_name}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = var.project_name
  }
}

resource "azurerm_managed_disk" "main" {
  count                = var.vm_count
  name                 = "${var.project_name}-os_disk-${count.index}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "30"

  tags = {
    environment = var.project_name
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = var.vm_count
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  managed_disk_id    = azurerm_managed_disk.main[count.index].id
  lun                = 0
  caching            = "None"
}

resource "azurerm_linux_virtual_machine" "main" {
  count               = var.vm_count
  name                = "${var.project_name}-vm-${count.index}"
  availability_set_id = azurerm_availability_set.main.id
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_id = data.azurerm_image.image.id

  tags = {
    environment = var.project_name
  }
}
