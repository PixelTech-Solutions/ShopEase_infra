locals {
  # Naming convention:  shopease-{env}-{resource}
  prefix       = "shopease-${var.environment}"
  acr_name     = "shopease${var.environment}acr"  # ACR: no hyphens allowed
  storage_name = "shopease${var.environment}stor" # Storage: no hyphens
  kv_name      = "${local.prefix}-kv"
  bus_name     = "${local.prefix}-bus"

  common_tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }

  # Container Apps that need SystemAssigned identity (all backend services)
  backend_services = ["user-service", "product-service", "order-service", "notification-service", "api-gateway"]

  # Internal base URL pattern for Container Apps inter-service communication
  internal_url = "https://%s.internal.${module.container_apps_env.default_domain}"

  # Placeholder image for initial deployment (before app CI pushes real images)
  placeholder_image = "mcr.microsoft.com/k8se/quickstart:latest"
}
