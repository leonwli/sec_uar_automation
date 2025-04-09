variable "uar_ent_app_name" {
  description = "Name for the enterprise app to authenticate to Entra and SharePoint"
  type        = string
}

variable "sec_uar_ps_script_name" {
  description = "Name for the enterprise app to authenticate to Entra and SharePoint"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure location for resources"
  type        = string
}

variable "automation_account" {
  description = "name of the automation account"
  type        = string
}

variable "runbook_name" {
  description = "Name of the runbook to create"
  type        = string
}

variable "runbook_script_path" {
  description = "file path of the Powershell script"
  type        = string
}

variable "connection_name" {
  description = "sec_uar_sp_cert_sharepoint connection name"
  type        = string
}

variable "storage_container_scripts" {
  description = "storage_container name"
  type        = string
  default     = "automation_script_container"
}