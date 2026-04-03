variable "name" {
  description = "Service Bus namespace name (globally unique)"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type    = string
  default = "Basic"
}

variable "queues" {
  description = "List of queue names to create"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
