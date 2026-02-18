# =============================================================================
# Azure Database for PostgreSQL Flexible Server
# =============================================================================
resource "azurerm_postgresql_flexible_server" "main" {
  name                          = "${local.prefix}-postgres"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  version                       = var.postgres_version
  administrator_login           = var.postgres_admin_username
  administrator_password        = var.postgres_admin_password
  storage_mb                    = var.postgres_storage_mb
  sku_name                      = var.postgres_sku
  backup_retention_days         = 30
  delegated_subnet_id           = azurerm_subnet.postgres.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]

  tags = azurerm_resource_group.main.tags
}

resource "azurerm_postgresql_flexible_server_database" "moto" {
  name      = "moto"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "utf8"
  collation = "en_US.utf8"
}
