variable "automation_account" {
  description = "automation_account name"
  type        = string
  default     = "azautomation"
}

variable "pfx_path" {
  description = "file path of the certificate private key"
  type        = string
  default     = "value"
}

variable "storage_container_scripts" {
  description = "storage_container name"
  type        = string
  default     = "automation_script_container"
}