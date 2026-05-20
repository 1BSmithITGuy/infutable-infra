# Builds Ubuntu 24.04 LTS Server template on Proxmox.
#  -  Autoinstall via cloud-init (NoCloud)
#  -  Updates applied
#  -  Baseline packages and config installed
#  -  UFW locked to jump host SSH only
#  -  cloud-init state cleaned
#
# Prerequisites:
#   - Ubuntu 24.04 server ISO uploaded to Proxmox ISO storage (named: ubuntu-24.04-server.iso)
#
# Usage:
#  build.sh (logs to /srv/logs/packer/ubuntu-24.04-server)
#     NOTE:  use -force if template exists to overwrite.

#  For manual build:
#     packer init .
#     packer build -var-file="ubuntu-24.04-server.pkrvars.hcl" .

# Reference:
#   https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox
#   https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html
#   https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/file/templatefile
#   https://docs.cloud-init.io/en/latest/reference/datasources/nocloud.html

packer {
  required_version = "~> 1.15"

  required_plugins {
    proxmox = {
      version = "~> 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  user_data = templatefile("${path.root}/http/user-data.pkrtpl", {
    automation_username = var.automation_username
    ssh_pubkey          = var.ssh_authorized_pubkey
  })
}

# =============================================================================
# Create VM:
# =============================================================================

source "proxmox-iso" "ubuntu-24-04-server" {

  # --- Proxmox connection ---------------------------------------------------
  proxmox_url              = var.proxmox_api_url
  node                     = var.proxmox_node
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = var.proxmox_tls_insecure

  # --- Template info -------------------------------------------------------
  vm_name              = var.template_name
  vm_id                = var.template_vm_id
  template_description = "Packer - Ubuntu 24.04 LTS Server (requires cloud-init)."
  tags                 = "template;ubuntu-server-24-04;linux;packer"

  # --- VM specs -----------------------------------------------------------
  os       = "l26"
  bios     = "ovmf"
  machine  = "q35"
  cores    = 2
  sockets  = 1
  cpu_type = "host" #   lab - this could fail on live migration if CPU isn't exactly the same
  memory   = 4096

  efi_config {
    efi_storage_pool  = var.datastore
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  scsi_controller = "virtio-scsi-single"

  disks {
    type         = "scsi"
    disk_size    = "12G"
    storage_pool = var.datastore
    format       = "raw"
    io_thread    = true
    discard      = true
    ssd          = true
  }

  network_adapters {
    model    = "virtio"
    bridge   = var.network_bridge
    vlan_tag = var.build_vlan
  }

  # OS:
  boot_iso {
    iso_file = "${var.iso_storage_pool}:iso/${var.ubuntu_iso_file}"
    unmount  = true
  }

  qemu_agent = true

  # --- Boot_command -------------------------------------------------------
  # Manually "types" at the console to add boot parameters in the grub cli
  #   so the installer can get the autoinstall and cloud-config IP/port (on packer host).

  # Lab: 
  #      -  I would be more inclined to use an ISO or PXE in prod.
  #      -  Hoping this template will work with other versions of Ubuntu, 
  #             and this could be an issue with different versions vs PXE or ISO.

  boot = "order=scsi0;ide2"

  #  Time to wait before typing commands (boot_command below)
  boot_wait = "10s"

  boot_command = [
    #  1 second wait, hit 'e' (GRUB edit menu), 1 second wait
    "<wait>e<wait>",
    # Hit down 3 times, then end of line
    "<down><down><down><end>",
    # backspaces (4) to delete " ---"
    "<bs><bs><bs><bs>",
    # Tells subiquity to look for cloud-init config from Packer's http server. 
    # http_content below specifies the http server/config
    # \\ - escape characters (2 of them - one for packer and the other for grub)
    " autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ ---",
    # Wait 1 sec, then hit F10 to boot
    "<wait><f10>"
  ]

  # Cloud-init/NoCloud via http:
  http_content = {
    "/user-data" = local.user_data
    "/meta-data" = file("${path.root}/http/meta-data")
  }

  # --- SSH ------------------------------------------------------------------
  # Packer connects via SSH after autoinstall completes and reboots.
  # Proxmox-iso plugin discovers the VM's IP via qemu-guest-agent on reboot (this avoids SSH into installer)

  communicator           = "ssh"
  ssh_username           = var.automation_username
  ssh_private_key_file   = var.ssh_private_key_file
  ssh_port               = 22
  ssh_timeout            = "30m"
  ssh_handshake_attempts = 30
}

# =============================================================================
# Build template:
# =============================================================================

build {
  sources = ["source.proxmox-iso.ubuntu-24-04-server"]

  # --- Stage source files in /tmp -------------------------------------------

  provisioner "shell" {
    inline = [
      "mkdir -p /tmp/packer-files"
    ]
  }

  # copy files (dotfiles, drop-in configs, etc)
  provisioner "file" {
    source      = "${path.root}/files/"
    destination = "/tmp/packer-files/"
  }

  # --- Provisioner sequence -------------------------------------------------
  # 3 scripts: build the image (baseline), lock the firewall (hardening), strip instance state (cleanup).
  # Each script is idempotent.
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "NEEDRESTART_MODE=a",
      "AUTOMATION_USERNAME=${var.automation_username}",
      "JUMP_HOST_IP=${var.jump_host_ip}"
    ]

    scripts = [
      "${path.root}/scripts/baseline.sh",
      "${path.root}/scripts/hardening.sh",
      "${path.root}/scripts/cleanup.sh"
    ]
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E bash '{{ .Path }}'"

  }
}