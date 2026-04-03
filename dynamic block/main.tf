resource "azurerm_resource_group" "rg" {
  name     = "rg_nandu"
  location = "west us"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtnetnandu"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  dynamic "subnet" {
    for_each = var.subnetnandu
    content {
      name             = subnet.key
      address_prefixes = subnet.value
    }
  }
}


resource "azurerm_network_security_group" "nsg" {
  name                = "nsg_rule"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = var.nsg
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_storage_account" "stg" {
  name                     = var.stg_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  dynamic network_rules {
    for_each = var.network_rules
    content {
    default_action             = network_rules.value.default_action
    ip_rules                   = network_rules.value.ip_rules
    virtual_network_subnet_ids = [azurerm_subnet.subnett.id]
    }
  }
}

resource "azurerm_subnet" "subnett" {
  for_each             = var.subnetnandu
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value
}