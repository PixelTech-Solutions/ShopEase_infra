# ─────────────────────────────────────────────────────────────────────────────
#  Resource Group
# ─────────────────────────────────────────────────────────────────────────────
output "resource_group_name" {
  value = module.resource_group.name
}

# ─────────────────────────────────────────────────────────────────────────────
#  Container Registry
# ─────────────────────────────────────────────────────────────────────────────
output "acr_login_server" {
  value = module.acr.login_server
}

output "acr_name" {
  value = module.acr.name
}

# ─────────────────────────────────────────────────────────────────────────────
#  Container Apps — URLs
# ─────────────────────────────────────────────────────────────────────────────
output "frontend_url" {
  value = "https://${module.frontend.fqdn}"
}

output "api_gateway_url" {
  value = "https://${module.api_gateway.fqdn}"
}

output "container_apps_env_default_domain" {
  value = module.container_apps_env.default_domain
}

# ─────────────────────────────────────────────────────────────────────────────
#  Monitoring
# ─────────────────────────────────────────────────────────────────────────────
output "app_insights_connection_string" {
  value     = module.app_insights.connection_string
  sensitive = true
}

output "log_analytics_workspace_id" {
  value = module.log_analytics.workspace_id
}

# ─────────────────────────────────────────────────────────────────────────────
#  Key Vault
# ─────────────────────────────────────────────────────────────────────────────
output "keyvault_uri" {
  value = module.keyvault.vault_uri
}

# ─────────────────────────────────────────────────────────────────────────────
#  Storage
# ─────────────────────────────────────────────────────────────────────────────
output "storage_blob_endpoint" {
  value = module.storage.primary_blob_endpoint
}

# ─────────────────────────────────────────────────────────────────────────────
#  Service Bus
# ─────────────────────────────────────────────────────────────────────────────
output "servicebus_namespace" {
  value = module.service_bus.name
}
