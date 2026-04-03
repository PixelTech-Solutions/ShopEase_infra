# =============================================================================
# ShopEase — UAT Environment
# =============================================================================

environment  = "uat"
location     = "eastus"
project_name = "shopease"

# ── Compute sizing (mirrors production shape at lower scale) ─────────────────
container_cpu    = 0.5
container_memory = "1Gi"
min_replicas     = 1
max_replicas     = 3

# ── SKUs ─────────────────────────────────────────────────────────────────────
acr_sku        = "Standard"
servicebus_sku = "Standard"

image_tag = "latest"
