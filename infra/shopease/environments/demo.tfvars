# =============================================================================
# ShopEase — Demo Environment
# =============================================================================

environment  = "demo"
location     = "eastus"
project_name = "shopease"

# ── Compute sizing (minimal — for demos / showcases) ─────────────────────────
container_cpu    = 0.25
container_memory = "0.5Gi"
min_replicas     = 0
max_replicas     = 1

# ── SKUs ─────────────────────────────────────────────────────────────────────
acr_sku        = "Basic"
servicebus_sku = "Basic"

image_tag = "latest"
