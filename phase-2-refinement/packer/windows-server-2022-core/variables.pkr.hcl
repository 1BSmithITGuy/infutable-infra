# Variable declarations for the Windows Server 2022 Core template build.
# Actual values go in a .pkrvars.hcl file (gitignored).

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
  default = "tmpl-ws2022-core"
}

variable "template_vm_id" {
  type        = number
  description = "VM ID for the template (must not already exist)"
  default     = 9000
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
  description = "Where the iso's are...."
  default     = "local"
}

# =============================================================================
# ISO names (in var.iso_storage_pool above)
# =============================================================================

variable "windows_iso_file" {
  type        = string
  description = "Windows Server 2022 ISO filename"
}

variable "build_tools_iso_file" {
  type        = string
  description = "Build tools ISO: VirtIO drivers, autounattend.xml, SSU bootstrap MSU"
  default     = "ws2022-build-tools.iso"
}

# =============================================================================
# Credentials
# =============================================================================

variable "admin_password" {
  type        = string
  description = "Local Administrator password - must match autounattend.xml"
  sensitive   = true
}
