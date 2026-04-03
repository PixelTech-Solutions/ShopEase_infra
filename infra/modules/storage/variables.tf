variable "name" {
  description = "Storage account name (globally unique, lowercase alphanumeric)"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "replication_type" {
  type    = string
  default = "LRS"
}

variable "allow_blob_public_access" {
  type    = bool
  default = true
}

variable "container_access_type" {
  description = "Access level for blob containers (private, blob, container)"
  type        = string
  default     = "blob"
}

variable "blob_containers" {
  description = "List of blob container names to create"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
