# ==============================================================
# Proxmox connection:
# ==============================================================

variable "proxmox_api_url" {
  description = "Proxmox host URL (e.g. https://pve.example.com:8006)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token <user@realm!tokenid=token-secret>"
  type        = string
  sensitive   = true
}

#  Lab:  use TLS in prod
variable "proxmox_tls_insecure" {
  description = "Skip TLS cert verification"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Proxmox node short name (from Proxmox UI - usually short hostname)"
  type        = string
}

# Template:  -----------------------------------------------------
#  Proxmox specific value (each VM has a unique ID):
variable "template_vm_id" {
  description = "Source Proxmox template (each Proxmox VM/template has a unique ID)"
  type        = number
  default     = 9000
}

# ==============================================================
# Domain controllers (per server values):
# ==============================================================

variable "domain_controllers" {
  description = "Map of domain controllers to deploy. Key is short name (e.g. dc03)."
  type = map(object({
    vm_id     = number
    hostname  = string
    static_ip = string
  }))
}

# ==============================================================
# Shared defaults (apply to all DCs):
# ==============================================================

variable "net_prefix" {
  description = "Subnet prefix"
  type        = number
  default     = 26
}

variable "gateway_ip" {
  description = "Gateway"
  type        = string
  default     = "10.0.1.1"
}

# temporary - Ansible handles assigning DNS properly, just need one.
variable "dns_ip" {
  description = "DNS server IP"
  type        = string
  default     = "10.0.1.3"
}

# WinRM connection (local admin on the new VM):  -----------------

variable "winrm_user" {
  description = "Local admin user (template)"
  type        = string
  default     = "Administrator"
}

variable "winrm_password" {
  description = "Local admin password (template)"
  type        = string
  sensitive   = true
}

# Proxmox storage:  -----------------------------------------------------

variable "datastore" {
  description = "Proxmox datastore"
  type        = string
  default     = "local-zfs"
}
