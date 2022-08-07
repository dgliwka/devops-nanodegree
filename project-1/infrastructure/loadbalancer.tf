resource "azurerm_public_ip" "main" {
  name                = "${var.project_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.project_name
  }
}

resource "azurerm_lb" "main" {
  name                = "${var.project_name}-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.project_name}-ip-config"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    environment = var.project_name
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  name            = "${var.project_name}-bap"
  loadbalancer_id = azurerm_lb.main.id

}

resource "azurerm_lb_backend_address_pool_address" "main" {
  count                   = var.vm_count
  name                    = "${var.project_name}-bap-address-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = azurerm_linux_virtual_machine.main[count.index].private_ip_address
}

resource "azurerm_lb_rule" "main" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "${var.project_name}-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.project_name}-ip-config"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id = azurerm_lb_probe.main.id
}

resource "azurerm_lb_probe" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "${var.project_name}-http-probe"
  port            = 80
  protocol        = "Http"
  request_path = "/"
  interval_in_seconds = 5
}
