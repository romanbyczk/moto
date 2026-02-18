project_name        = "moto"
environment         = "prod"
location            = "westeurope"
aks_node_count      = 2
aks_node_vm_size    = "Standard_D2s_v3"
aks_max_node_count  = 4
postgres_sku        = "GP_Standard_D2s_v3"
postgres_storage_mb = 32768
postgres_version    = "16"
redis_sku           = "Basic"
redis_family        = "C"
redis_capacity      = 1

# postgres_admin_password is intentionally omitted.
# Provide via: export TF_VAR_postgres_admin_password="your-secure-password"
