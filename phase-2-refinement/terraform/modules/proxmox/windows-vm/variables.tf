# Required -----------------------------------------------------

variable "hostname" {
  description = "Hostname (also the Proxmox VM name)"
  type        = string
}

variable "proxmox_node" {
  description = "Proxmox host to deploy VM on"
  type        = string
}

variable "template_vm_id" {
  description = "VM ID of the Windows Server template to clone"
  type        = number
}

variable "protection" {
  description = "Enable VM protection"
  type        = bool
  default     = true
}

# Optional variables --------------------------------------------------

variable "vm_id" {
  description = "Proxmox VM ID (100+).  0 will auto-assign"
  type        = number

  validation {
    condition     = var.vm_id >= 0
    error_message = "vm_id must be 0 or greater"
  }
}

variable "description" {
  description = "VM description in Proxmox"
  type        = string
  default     = "Managed by Terraform"
}

variable "tags" {
  description = "Tags"
  type        = list(string)
  default     = ["terraform", "windows"]
}

variable "cpu_cores" {
  description = "How many CPU cores to assign"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 4096
}

variable "os_disk_size_gb" {
  description = "OS disk (C:) - in GB"
  type        = number
  default     = 60
}

variable "additional_disks" {
  description = "Additional data disks (scsi1, scsi2, etc). Order determines disk number in the OS."
  type = list(object({
    size_gb = number
  }))
  default = []
}

variable "datastore" {
  description = "Datastore for VMDKs"
  type        = string
  default     = "local-zfs"
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "VLAN tag"
  type        = number
  default     = null
}

variable "start_on_boot" {
  description = "Start VM automatically when host boots"
  type        = bool
  default     = true
}

# Bootstrap (optional) ----------------------------------------------------
# Set bootstrap_network to configure static IP and hostname via WinRM
# after clone. Leave null to skip bootstrap entirely.

variable "bootstrap_network" {
  description = "Static IP config applied via WinRM after clone. Null to skip."
  type = object({
    static_ip     = string
    prefix_length = number
    gateway       = string
    dns           = string
  })
  default = null
}

variable "winrm_user" {
  description = "WinRM username for bootstrap connection"
  type        = string
  default     = null
}

variable "winrm_password" {
  description = "WinRM password for bootstrap connection"
  type        = string
  sensitive   = true
  default     = null
}
