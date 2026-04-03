output "id" {
  value = azurerm_container_app.this.id
}

output "name" {
  value = azurerm_container_app.this.name
}

output "fqdn" {
  value = try(azurerm_container_app.this.ingress[0].fqdn, null)
}

output "latest_revision_fqdn" {
  value = azurerm_container_app.this.latest_revision_fqdn
}

output "identity_principal_id" {
  value = try(azurerm_container_app.this.identity[0].principal_id, null)
}

output "outbound_ip_addresses" {
  value = azurerm_container_app.this.outbound_ip_addresses
}
