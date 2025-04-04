# Configure the Microsoft Azure Provider
provider "azurerm" {
  use_oidc                        = true
  resource_provider_registrations = "none"
  subscription_id                 = "73cf1747-3dc8-4f98-91fd-4f6cba3bfd3e"
  features {
    resource_group { prevent_deletion_if_contains_resources = false }
  }
}

provider "azuread" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.25.0"
    }
  }
  backend "azurerm" {
    subscription_id      = "73cf1747-3dc8-4f98-91fd-4f6cba3bfd3e"
    resource_group_name  = "terraform_rg"
    storage_account_name = "bctfstorageaccount"
    container_name       = "tfstorage"
    key                  = "terraform.tfstate"
  }
}