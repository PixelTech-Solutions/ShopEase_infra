# ─────────────────────────────────────────────────────────────────────────────
#  General
# ─────────────────────────────────────────────────────────────────────────────
variable "environment" {
  description = "Environment name (dev, qa, uat, prod, demo)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Logical project name"
  type        = string
  default     = "shopease"
}

# ─────────────────────────────────────────────────────────────────────────────
#  Container App sizing
# ─────────────────────────────────────────────────────────────────────────────
variable "container_cpu" {
  type    = number
  default = 0.25
}

variable "container_memory" {
  type    = string
  default = "0.5Gi"
}

variable "min_replicas" {
  type    = number
  default = 0
}

variable "max_replicas" {
  type    = number
  default = 1
}

# ─────────────────────────────────────────────────────────────────────────────
#  ACR
# ─────────────────────────────────────────────────────────────────────────────
variable "acr_sku" {
  type    = string
  default = "Basic"
}

# ─────────────────────────────────────────────────────────────────────────────
#  Service Bus
# ─────────────────────────────────────────────────────────────────────────────
variable "servicebus_sku" {
  type    = string
  default = "Basic"
}

# ─────────────────────────────────────────────────────────────────────────────
#  Container image tags  — overridden per deployment
# ─────────────────────────────────────────────────────────────────────────────
variable "image_tag" {
  description = "Docker image tag to deploy (e.g. git SHA or 'latest')"
  type        = string
  default     = "latest"
}

# ─────────────────────────────────────────────────────────────────────────────
#  Secrets — passed in via CI or .auto.tfvars (never committed!)
# ─────────────────────────────────────────────────────────────────────────────
variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "mongodb_uri_users" {
  description = "MongoDB connection string for user-service"
  type        = string
  sensitive   = true
  default     = ""
}

variable "mongodb_uri_products" {
  description = "MongoDB connection string for product-service"
  type        = string
  sensitive   = true
  default     = ""
}

variable "mongodb_uri_orders" {
  description = "MongoDB connection string for order-service"
  type        = string
  sensitive   = true
  default     = ""
}

variable "mongodb_uri_notifications" {
  description = "MongoDB connection string for notification-service"
  type        = string
  sensitive   = true
  default     = ""
}
