#  Output to root module

output "vm_id" {
  description = "Proxmox VM ID of the created VM"
  value       = proxmox_virtual_environment_vm.windows_vm.vm_id
}

output "ipv4_addresses" {
  description = "IP addresses reported by the QEMU guest agent"
  value       = flatten(proxmox_virtual_environment_vm.windows_vm.ipv4_addresses)
}
