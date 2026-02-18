variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
  default     = "moto"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.project_name))
    error_message = "Project name must be lowercase alphanumeric with hyphens, 2-21 characters, starting with a letter."
  }
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

# AKS
variable "aks_node_count" {
  description = "Number of AKS nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.aks_node_count >= 1 && var.aks_node_count <= 100
    error_message = "AKS node count must be between 1 and 100."
  }
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "aks_authorized_ip_ranges" {
  description = "List of authorized IP ranges for AKS API server access"
  type        = list(string)
  default     = []
}

variable "aks_max_node_count" {
  description = "Max nodes for autoscaler"
  type        = number
  default     = 4

  validation {
    condition     = var.aks_max_node_count >= 1 && var.aks_max_node_count <= 100
    error_message = "AKS max node count must be between 1 and 100."
  }
}

# PostgreSQL
variable "postgres_sku" {
  description = "PostgreSQL Flexible Server SKU"
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "postgres_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 32768

  validation {
    condition     = var.postgres_storage_mb >= 32768 && var.postgres_storage_mb <= 16777216
    error_message = "PostgreSQL storage must be between 32768 MB (32 GB) and 16777216 MB (16 TB)."
  }
}

variable "postgres_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"

  validation {
    condition     = contains(["13", "14", "15", "16", "17"], var.postgres_version)
    error_message = "PostgreSQL version must be one of: 13, 14, 15, 16, 17."
  }
}

variable "postgres_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "motoadmin"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{2,62}$", var.postgres_admin_username))
    error_message = "Username must start with a letter, contain only alphanumeric characters and underscores, 3-63 characters."
  }
}

variable "postgres_admin_password" {
  description = "PostgreSQL admin password (provide via TF_VAR_postgres_admin_password)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.postgres_admin_password) >= 8 && length(var.postgres_admin_password) <= 128
    error_message = "PostgreSQL admin password must be between 8 and 128 characters."
  }
}

# Redis
variable "redis_sku" {
  description = "Redis cache SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.redis_sku)
    error_message = "Redis SKU must be one of: Basic, Standard, Premium."
  }
}

variable "redis_family" {
  description = "Redis cache family (C for Basic/Standard, P for Premium)"
  type        = string
  default     = "C"

  validation {
    condition     = contains(["C", "P"], var.redis_family)
    error_message = "Redis family must be C (Basic/Standard) or P (Premium)."
  }
}

variable "redis_capacity" {
  description = "Redis cache size (0-6)"
  type        = number
  default     = 1

  validation {
    condition     = var.redis_capacity >= 0 && var.redis_capacity <= 6
    error_message = "Redis capacity must be between 0 and 6."
  }
}
