variable "name" {
  description = "Container App name"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "identity_type" {
  description = "Managed identity type (SystemAssigned, None)"
  type        = string
  default     = "SystemAssigned"
}

variable "container_image" {
  description = "Full container image reference (registry/image:tag)"
  type        = string
}

variable "cpu" {
  type    = number
  default = 0.25
}

variable "memory" {
  description = "Memory in Gi (e.g. 0.5Gi)"
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  type    = number
  default = 0
}

variable "max_replicas" {
  type    = number
  default = 1
}

variable "env_vars" {
  description = "List of environment variable objects {name, value}"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "ingress_enabled" {
  type    = bool
  default = true
}

variable "ingress_external" {
  description = "true = internet-facing, false = internal only"
  type        = bool
  default     = false
}

variable "ingress_target_port" {
  type    = number
  default = 80
}

variable "registry_server" {
  type    = string
  default = null
}

variable "registry_username" {
  type      = string
  default   = null
  sensitive = true
}

variable "registry_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
