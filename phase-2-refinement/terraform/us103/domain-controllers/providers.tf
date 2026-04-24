# State is stored locally. Prod should use a shared backend (locking, shared access with team)

terraform {
  required_version = "~> 1.14"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.98"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_tls_insecure
}
