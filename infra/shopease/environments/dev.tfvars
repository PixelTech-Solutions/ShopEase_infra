# =============================================================================
# ShopEase — Dev Environment
# =============================================================================
# State key:  shopease/shopease/dev/terraform.tfstate
# =============================================================================

environment  = "dev"
location     = "eastus"
project_name = "shopease"

# ── Compute sizing (minimal for dev) ─────────────────────────────────────────
container_cpu    = 0.25
container_memory = "0.5Gi"
min_replicas     = 0
max_replicas     = 1

# ── SKUs ─────────────────────────────────────────────────────────────────────
acr_sku       = "Basic"
servicebus_sku = "Basic"

# ── Image tag (overridden by CI) ─────────────────────────────────────────────
image_tag = "latest"
