# =============================================================================
#  ShopEase — Complete Azure Infrastructure
# =============================================================================
#  Resources created (per environment, in a dedicated resource group):
#    • Resource Group
#    • Azure Container Registry
#    • Log Analytics Workspace  +  Application Insights
#    • Azure Key Vault (with managed-identity access for every backend service)
#    • Azure Service Bus  (queue: order-notifications)
#    • Azure Blob Storage (container: product-images)
#    • Container Apps Environment
#    • 6 Container Apps  (frontend, api-gateway, user, product, order, notification)
# =============================================================================

# ── 1. Resource Group ─────────────────────────────────────────────────────────
module "resource_group" {
  source   = "../modules/resource-group"
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# ── 2. Container Registry ────────────────────────────────────────────────────
module "acr" {
  source              = "../modules/acr"
  name                = local.acr_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = var.acr_sku
  admin_enabled       = true
  tags                = local.common_tags
}

# ── 3. Log Analytics ─────────────────────────────────────────────────────────
module "log_analytics" {
  source              = "../modules/log-analytics"
  name                = "${local.prefix}-logs"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = 30
  tags                = local.common_tags
}

# ── 4. Application Insights ──────────────────────────────────────────────────
module "app_insights" {
  source                     = "../modules/app-insights"
  name                       = "${local.prefix}-insights"
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  log_analytics_workspace_id = module.log_analytics.id
  retention_in_days          = 90
  tags                       = local.common_tags
}

# ── 5. Service Bus ───────────────────────────────────────────────────────────
module "service_bus" {
  source              = "../modules/service-bus"
  name                = local.bus_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = var.servicebus_sku
  queues              = ["order-notifications"]
  tags                = local.common_tags
}

# ── 6. Blob Storage ──────────────────────────────────────────────────────────
module "storage" {
  source                   = "../modules/storage"
  name                     = local.storage_name
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  replication_type         = "LRS"
  allow_blob_public_access = true
  container_access_type    = "blob"
  blob_containers          = ["product-images"]
  tags                     = local.common_tags
}

# ── 7. Container Apps Environment ────────────────────────────────────────────
module "container_apps_env" {
  source                     = "../modules/container-apps-env"
  name                       = "${local.prefix}-env"
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = local.common_tags
}

# ── 8. Key Vault (created before Container Apps — no cycle) ──────────────────
module "keyvault" {
  source              = "../modules/keyvault"
  name                = local.kv_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.common_tags

  secrets = {
    "jwt-secret"                   = var.jwt_secret
    "user-mongodb-uri"             = var.mongodb_uri_users
    "product-mongodb-uri"          = var.mongodb_uri_products
    "order-mongodb-uri"            = var.mongodb_uri_orders
    "notification-mongodb-uri"     = var.mongodb_uri_notifications
    "servicebus-connection-string" = module.service_bus.default_primary_connection_string
    "storage-connection-string"    = module.storage.primary_connection_string
  }
}

# ── 9. Container Apps ────────────────────────────────────────────────────────

# 9a — User Service (internal)
module "user_service" {
  source                       = "../modules/container-app"
  name                         = "user-service"
  resource_group_name          = module.resource_group.name
  container_app_environment_id = module.container_apps_env.id
  container_image              = var.image_tag == "latest" ? local.placeholder_image : "${module.acr.login_server}/user-service:${var.image_tag}"
  cpu                          = var.container_cpu
  memory                       = var.container_memory
  min_replicas                 = var.min_replicas
  max_replicas                 = var.max_replicas
  ingress_enabled              = true
  ingress_external             = false
  ingress_target_port          = 3001
  identity_type                = "SystemAssigned"
  registry_server              = module.acr.login_server
  registry_username            = module.acr.admin_username
  registry_password            = module.acr.admin_password
  tags                         = local.common_tags

  env_vars = [
    { name = "PORT", value = "3001" },
    { name = "NODE_ENV", value = "production" },
    { name = "KEY_VAULT_URL", value = module.keyvault.vault_uri },
    { name = "APPINSIGHTS_CONNECTION_STRING", value = module.app_insights.connection_string },
  ]
}

# 9b — Product Service (internal)
module "product_service" {
  source                       = "../modules/container-app"
  name                         = "product-service"
  resource_group_name          = module.resource_group.name
  container_app_environment_id = module.container_apps_env.id
  container_image              = var.image_tag == "latest" ? local.placeholder_image : "${module.acr.login_server}/product-service:${var.image_tag}"
  cpu                          = var.container_cpu
  memory                       = var.container_memory
  min_replicas                 = var.min_replicas
  max_replicas                 = var.max_replicas
  ingress_enabled              = true
  ingress_external             = false
  ingress_target_port          = 3002
  identity_type                = "SystemAssigned"
  registry_server              = module.acr.login_server
  registry_username            = module.acr.admin_username
  registry_password            = module.acr.admin_password
  tags                         = local.common_tags

  env_vars = [
    { name = "PORT", value = "3002" },
    { name = "NODE_ENV", value = "production" },
    { name = "USER_SERVICE_URL", value = format(local.internal_url, "user-service") },
    { name = "KEY_VAULT_URL", value = module.keyvault.vault_uri },
    { name = "APPINSIGHTS_CONNECTION_STRING", value = module.app_insights.connection_string },
    { name = "AZURE_STORAGE_CONNECTION_STRING", value = module.storage.primary_connection_string },
    { name = "AZURE_STORAGE_CONTAINER_NAME", value = "product-images" },
  ]
}

# 9c — Order Service (internal)
module "order_service" {
  source                       = "../modules/container-app"
  name                         = "order-service"
  resource_group_name          = module.resource_group.name
  container_app_environment_id = module.container_apps_env.id
  container_image              = var.image_tag == "latest" ? local.placeholder_image : "${module.acr.login_server}/order-service:${var.image_tag}"
  cpu                          = var.container_cpu
  memory                       = var.container_memory
  min_replicas                 = var.min_replicas
  max_replicas                 = var.max_replicas
  ingress_enabled              = true
  ingress_external             = false
  ingress_target_port          = 3003
  identity_type                = "SystemAssigned"
  registry_server              = module.acr.login_server
  registry_username            = module.acr.admin_username
  registry_password            = module.acr.admin_password
  tags                         = local.common_tags

  env_vars = [
    { name = "PORT", value = "3003" },
    { name = "NODE_ENV", value = "production" },
    { name = "USER_SERVICE_URL", value = format(local.internal_url, "user-service") },
    { name = "PRODUCT_SERVICE_URL", value = format(local.internal_url, "product-service") },
    { name = "NOTIFICATION_SERVICE_URL", value = format(local.internal_url, "notification-service") },
    { name = "KEY_VAULT_URL", value = module.keyvault.vault_uri },
    { name = "APPINSIGHTS_CONNECTION_STRING", value = module.app_insights.connection_string },
    { name = "SERVICE_BUS_CONNECTION_STRING", value = module.service_bus.default_primary_connection_string },
  ]
}

# 9d — Notification Service (internal)
module "notification_service" {
  source                       = "../modules/container-app"
  name                         = "notification-service"
  resource_group_name          = module.resource_group.name
  container_app_environment_id = module.container_apps_env.id
  container_image              = var.image_tag == "latest" ? local.placeholder_image : "${module.acr.login_server}/notification-service:${var.image_tag}"
  cpu                          = var.container_cpu
  memory                       = var.container_memory
  min_replicas                 = var.min_replicas
  max_replicas                 = var.max_replicas
  ingress_enabled              = true
  ingress_external             = false
  ingress_target_port          = 3004
  identity_type                = "SystemAssigned"
  registry_server              = module.acr.login_server
  registry_username            = module.acr.admin_username
  registry_password            = module.acr.admin_password
  tags                         = local.common_tags

  env_vars = [
    { name = "PORT", value = "3004" },
    { name = "NODE_ENV", value = "production" },
    { name = "USER_SERVICE_URL", value = format(local.internal_url, "user-service") },
    { name = "ORDER_SERVICE_URL", value = format(local.internal_url, "order-service") },
    { name = "KEY_VAULT_URL", value = module.keyvault.vault_uri },
    { name = "APPINSIGHTS_CONNECTION_STRING", value = module.app_insights.connection_string },
    { name = "SERVICE_BUS_CONNECTION_STRING", value = module.service_bus.default_primary_connection_string },
  ]
}

# 9e — API Gateway (external)
module "api_gateway" {
  source                       = "../modules/container-app"
  name                         = "api-gateway"
  resource_group_name          = module.resource_group.name
  container_app_environment_id = module.container_apps_env.id
  container_image              = var.image_tag == "latest" ? local.placeholder_image : "${module.acr.login_server}/api-gateway:${var.image_tag}"
  cpu                          = var.container_cpu
  memory                       = var.container_memory
  min_replicas                 = var.min_replicas
  max_replicas                 = var.max_replicas
  ingress_enabled              = true
  ingress_external             = true
  ingress_target_port          = 3000
  identity_type                = "SystemAssigned"
  registry_server              = module.acr.login_server
  registry_username            = module.acr.admin_username
  registry_password            = module.acr.admin_password
  tags                         = local.common_tags

  env_vars = [
    { name = "PORT", value = "3000" },
    { name = "NODE_ENV", value = "production" },
    { name = "USER_SERVICE_URL", value = format(local.internal_url, "user-service") },
    { name = "PRODUCT_SERVICE_URL", value = format(local.internal_url, "product-service") },
    { name = "ORDER_SERVICE_URL", value = format(local.internal_url, "order-service") },
    { name = "NOTIFICATION_SERVICE_URL", value = format(local.internal_url, "notification-service") },
    { name = "KEY_VAULT_URL", value = module.keyvault.vault_uri },
    { name = "APPINSIGHTS_CONNECTION_STRING", value = module.app_insights.connection_string },
  ]
}

# 9f — Frontend (external)
module "frontend" {
  source                       = "../modules/container-app"
  name                         = "frontend"
  resource_group_name          = module.resource_group.name
  container_app_environment_id = module.container_apps_env.id
  container_image              = var.image_tag == "latest" ? local.placeholder_image : "${module.acr.login_server}/frontend:${var.image_tag}"
  cpu                          = var.container_cpu
  memory                       = var.container_memory
  min_replicas                 = var.min_replicas
  max_replicas                 = var.max_replicas
  ingress_enabled              = true
  ingress_external             = true
  ingress_target_port          = 80
  identity_type                = "None"
  registry_server              = module.acr.login_server
  registry_username            = module.acr.admin_username
  registry_password            = module.acr.admin_password
  tags                         = local.common_tags

  env_vars = [
    { name = "API_GATEWAY_URL", value = format(local.internal_url, "api-gateway") },
  ]
}

# ── 10. Key Vault Access Policies (created after Container Apps) ──────────────
resource "azurerm_key_vault_access_policy" "container_apps" {
  for_each = {
    user_service         = module.user_service.identity_principal_id
    product_service      = module.product_service.identity_principal_id
    order_service        = module.order_service.identity_principal_id
    notification_service = module.notification_service.identity_principal_id
    api_gateway          = module.api_gateway.identity_principal_id
  }

  key_vault_id = module.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  secret_permissions = ["Get", "List"]
}
