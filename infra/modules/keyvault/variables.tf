variable "name" {
  description = "Key Vault name (globally unique)"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "container_app_identity_object_ids" {
  description = "Object IDs of Container App system-assigned managed identities"
  type        = list(string)
  default     = []
}

variable "secrets" {
  description = "Map of secret name → secret value to seed into the vault"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
