# Variable declarations for the Ubuntu 24.04 Server template build.

# =============================================================================
# Proxmox connection
# =============================================================================

variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API endpoint: https://<FQDN>:8006/api2/json"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "API token ID: user@realm!tokenname"
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "API token secret"
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  type        = bool
  description = "Skip TLS verification (lab with self-signed cert)"
  default     = false
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name (short name from UI header)"
}

# =============================================================================
# Template info
# =============================================================================

variable "template_name" {
  type    = string
  default = "tmpl-ubuntu-24-04-server"
}

variable "template_vm_id" {
  type        = number
  description = "VM ID for the template (must not already exist)"
  default     = 9001
}

# =============================================================================
# Storage
# =============================================================================

variable "datastore" {
  type    = string
  default = "local-zfs"
}

variable "iso_storage_pool" {
  type        = string
  description = "Where the ISOs are...."
  default     = "local"
}

# =============================================================================
# ISO names (in var.iso_storage_pool above)
# =============================================================================

variable "ubuntu_iso_file" {
  type        = string
  description = "Ubuntu Server ISO filename"
}

# =============================================================================
# Network
# =============================================================================

variable "network_bridge" {
  type    = string
  default = "vmbr1"
}

variable "build_vlan" {
  type        = number
  description = "VLAN tag (for build; not permanent)"
  default     = 15
}

variable "jump_host_ip" {
  type        = string
  description = "Jump host IP (for SSH firewall rule)"
}

# =============================================================================
# Identity / credentials
# =============================================================================

variable "automation_username" {
  type        = string
  description = "Automation service account (packer, terraform, ansible, etc)"
}

variable "ssh_authorized_pubkey" {
  type        = string
  description = "SSH public key for the automation service account (automation_username); stripped from the template by cleanup.sh."
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to the matching private key on the build host (used by Packer's SSH connection during build)"
}
