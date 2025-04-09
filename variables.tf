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

variable "resource_group" {
  default = "secautomation-rg"
}

variable "automation_account" {
  default = "secautomation"
}

variable "runbook_name" {
  default = "Export-AppAssignments"
}

variable "runbook_script_path" {
  default = "./runbook.ps1"
}

variable "pfx_path" {
  default = "./cert.pfx"
}

variable "pfx_password" {
  description = "Password for the PFX certificate"
  type        = string
  sensitive   = true
}

variable "connection_name" {
  default = "sec_uar_sp_cert_sharepoint"
}

variable "tenant_id" {}
