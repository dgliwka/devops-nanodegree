resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = var.project_name
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.project_name}-subnet-internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.main.id

  depends_on = [
    azurerm_network_security_rule.allow_internal_inbound,
    azurerm_network_security_rule.allow_internal_outbound,
    azurerm_network_security_rule.deny_internet_access,
    azurerm_network_security_rule.allow_http
  ]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.project_name}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = var.project_name
  }
}

resource "azurerm_network_security_rule" "allow22" {
  name                        = "allow22"
  description                 = "Allow 22"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "allow_http"
  description                 = "Allow http"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "allow_internal_inbound" {
  name                         = "allow_internal_inbound"
  description                  = "Allow internal traffic"
  priority                     = 100
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = azurerm_subnet.internal.address_prefixes
  destination_address_prefixes = azurerm_subnet.internal.address_prefixes
  resource_group_name          = azurerm_resource_group.main.name
  network_security_group_name  = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "allow_internal_outbound" {
  name                         = "allow_internal_outbound"
  description                  = "Allow internal traffic"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = azurerm_subnet.internal.address_prefixes
  destination_address_prefixes = azurerm_subnet.internal.address_prefixes
  resource_group_name          = azurerm_resource_group.main.name
  network_security_group_name  = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "deny_internet_access" {
  name                        = "deny_internet_access"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}
