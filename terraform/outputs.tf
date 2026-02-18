output "resource_group_name" {
  description = "Name of the Azure resource group"
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "Login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "postgres_fqdn" {
  description = "Fully qualified domain name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgres_database_url" {
  description = "Construct manually: postgres://<user>:<password>@<fqdn>:5432/moto?sslmode=require"
  value       = "postgres://${var.postgres_admin_username}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/moto?sslmode=require"
  sensitive   = true
}

output "redis_hostname" {
  description = "Hostname of the Azure Redis Cache instance"
  value       = azurerm_redis_cache.main.hostname
}

output "redis_primary_key" {
  description = "Primary access key for the Redis Cache"
  value       = azurerm_redis_cache.main.primary_access_key
  sensitive   = true
}

output "redis_connection_string" {
  description = "Construct manually: rediss://:<primary_key>@<hostname>:6380/0"
  value       = "rediss://${azurerm_redis_cache.main.hostname}:6380/0"
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}
