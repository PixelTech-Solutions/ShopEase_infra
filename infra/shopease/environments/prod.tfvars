# =============================================================================
# ShopEase — Production Environment
# =============================================================================

environment  = "prod"
location     = "eastus"
project_name = "shopease"

# ── Compute sizing (production-grade) ────────────────────────────────────────
container_cpu    = 0.5
container_memory = "1Gi"
min_replicas     = 1
max_replicas     = 5

# ── SKUs ─────────────────────────────────────────────────────────────────────
acr_sku       = "Standard"
servicebus_sku = "Standard"

image_tag = "latest"
