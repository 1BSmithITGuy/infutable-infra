# =============================================================================
# Domain Controller (ad.infutable.com) root module for all DCs
#
# Invoked from higher level orchestration script (/scripts/us103/deploy-dc.sh); please use that script.
#
# Description:  Deploys all Domain controllers in infutable with the same specs. 
#               Uses a map of objects variable and loop to create all DCs (see terraform.tfvars.example)
#
# Terraform:
#   1. Clone VM(s) from template
#   2. Boot with DHCP
#   3. Connect via WinRM and bootstrap hostname + static networking
#
# Notes:  
#     -  Post-bootstrap (domain join, DC promotion) is handled by Ansible.
#     -  This is a lab; production deployments use tighter controls around credentials and promoting DCs.
#           See future-project-ideas.md for Vault integration.
# =============================================================================


# Call child module, and Create a VM for each domain controller in the map:
module "dc" {

  for_each = var.domain_controllers

  source = "../../modules/proxmox/windows-vm"

  hostname       = each.value.hostname
  proxmox_node   = var.proxmox_node
  template_vm_id = var.template_vm_id
  protection     = false
  vm_id          = each.value.vm_id

  description = "Domain Controller - ad.infutable.com (Terraform managed)"
  tags        = ["terraform", "windows", "domain-controller", "us103", "adds"]

  cpu_cores       = 2
  memory_mb       = 2048
  os_disk_size_gb = 60
  datastore       = var.datastore

  # Lab - increase size for prod
  additional_disks = [
    { size_gb = 15 }, # D: NTDS database
    { size_gb = 10 }, # E: NTDS transaction logs
    { size_gb = 10 }, # F: SYSVOL
  ]

  network_bridge = "vmbr1"
  vlan_id        = 10

  start_on_boot = true

  # Bootstrap: set hostname and static IP via WinRM after clone
  bootstrap_network = {
    static_ip     = each.value.static_ip
    prefix_length = var.net_prefix
    gateway       = var.gateway_ip
    dns           = var.dns_ip
  }

  winrm_user     = var.winrm_user
  winrm_password = var.winrm_password
}

# =============================================================================
# Generate Ansible inventory from the domain_controllers variable.
# Single source of truth -- add a DC to terraform.tfvars, inventory follows.
# =============================================================================

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/hosts.yml.tftpl", {
    domain_controllers = var.domain_controllers
  })
  filename        = "${path.module}/../../../ansible/inventory/us103/domain-controllers.yml"
  file_permission = "0644"
}

# Phase II configuration (domain join, DC promotion) handled by Ansible.
