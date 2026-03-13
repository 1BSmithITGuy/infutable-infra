# Builds Windows Server 2022 Datacenter Core template on Proxmox.
#  -  Installs updates, virtio drivers, and QEMU agent
#  -  Configures WinRM for Ansible management

# Prerequisites:
#   - Windows Server 2022 ISO uploaded to Proxmox ISO storage
#   - VirtIO drivers ISO uploaded to Proxmox ISO storage 
#      (See phase-2-refinement/packer/windows-server-2022-core/README.md in infutable repo)
#
# Usage:
#  For logged builds, use build.sh (logs to /srv/logs/packer/) 
#     NOTE:  use -force if template exists to overwrite.
#
#  For manual build:
#     packer init .
#     packer build -var-file="windows-server-2022-core.pkrvars.hcl" .
#         NOTE:  use -force if template exists to overwrite.

# Reference:  
#   https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox
#   https://github.com/rgl/packer-plugin-windows-update

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/proxmox"
    }
    windows-update = {
      version = ">= 0.16.0"
      source  = "github.com/rgl/windows-update"
    }
  }
}

# =============================================================================
# Create VM:
# =============================================================================

source "proxmox-iso" "windows-server-2022-core" {

  # --- Proxmox connection ---------------------------------------------------
  proxmox_url              = var.proxmox_api_url
  node                     = var.proxmox_node
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = var.proxmox_tls_insecure  #  lab

  # --- Template info ---------------------------------------------------------
  vm_name              = var.template_name
  vm_id                = var.template_vm_id
  template_description = "Packer - Windows Server 2022 Datacenter Core"
  tags                 = "template;windows;server;packer"

  # --- VM specs --------------------------------------------------------------
  os       = "win11"
  bios     = "ovmf"
  machine  = "pc-i440fx-10.1"
  cores    = 2
  sockets  = 1
  cpu_type = "x86-64-v2-AES"
  memory   = 4096

  efi_config {
    efi_storage_pool  = var.datastore
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  tpm_config {
    tpm_storage_pool = var.datastore
  }

  scsi_controller = "virtio-scsi-single"

  disks {
    type         = "scsi"
    disk_size    = "60G"
    storage_pool = var.datastore
    format       = "raw"
    io_thread    = true
    discard      = true
  }

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr1"
    vlan_tag = 15
  }

  # Main OS:
  boot_iso {
    iso_file = "${var.iso_storage_pool}:iso/${var.windows_iso_file}"
    unmount  = true
  }

  # Build tools ISO -- VirtIO drivers, autounattend.xml, and CU.
  # See README.md for repack instructions.

  additional_iso_files {
    type     = "ide"
    index    = 3
    iso_file = "${var.iso_storage_pool}:iso/${var.build_tools_iso_file}"
    unmount  = true
  }

  # Agent is installed by install-virtio-ga.ps1 during provisioning.
  # Setting true so clones inherit agent=1 in Proxmox config.
  qemu_agent = true

  boot      = "order=ide2"
  boot_wait = "5s"
  boot_command = ["<spacebar>"]

  # --- WinRM --------------------------------------------------------------
  # Packer waits for WinRM to come up after Windows installs and auto-logon
  # runs the WinRM setup commands (defined in autounattend.xml).
  communicator   = "winrm"
  winrm_host     = "10.0.1.190"
  winrm_username = "Administrator"
  winrm_password = var.admin_password
  winrm_timeout  = "45m"
  winrm_insecure = true
}

# =============================================================================
# Build template:
# =============================================================================

build {
  sources = ["source.proxmox-iso.windows-server-2022-core"]

  # --- Install VirtIO drivers and QEMU agent --------------------------------
  provisioner "powershell" {
    script = "${path.root}/scripts/install-virtio-ga.ps1"
  }

  # --- Apply CU ----------------------------------------------------------
  provisioner "powershell" {
    script = "${path.root}/scripts/bootstrap-ssu.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  # --- Windows Updates (rgl/packer-plugin-windows-update) -------------------
  # Loops automatically (install-->reboot-->Install...)
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true",
    ]
    update_limit = 25
  }

  # --- Configure WinRM for Ansible ------------------------------------------
  # Downloads the official Ansible WinRM script, sets up HTTPS + CredSSP
  
  provisioner "powershell" {
    script = "${path.root}/scripts/configure-ansible.ps1"
  }

  # --- Cleanup/sysprep ------------------------------------------------------
  # Generates a sysprep unattend at runtime (keeps secrets out of the repo),
  # then runs sysprep via a scheduled task so the script can exit cleanly.
  provisioner "powershell" {
    script = "${path.root}/scripts/sysprep.ps1"
    environment_vars = [
      "ADMIN_PASSWORD=${var.admin_password}",
    ]
  }
}

# Packer detects the VM has stopped and converts it to a template.
