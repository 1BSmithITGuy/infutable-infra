# =============================================================================
# Child Module to Clone new VM from the Windows Server 2022 core template
# =============================================================================

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.98"
    }
  }
}

resource "proxmox_virtual_environment_vm" "windows_vm" {
  name       = var.hostname
  node_name  = var.proxmox_node
  protection = var.protection

  # -----------VM ID - Proxmox requires a unique ID------------------
  # If VM ID set to 0, then replace with null for auto-assign, else use vm_id
  vm_id = var.vm_id == 0 ? null : var.vm_id


  description = var.description
  tags        = var.tags

  # --- Which template to clone (Proxmox ID) ------------------------------------------
  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  # --- CPU/RAM ----------------------------------------------------------
  cpu {
    cores   = var.cpu_cores
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory_mb
  }

  # --- OS/agent ------------------------------------------------------------
  operating_system {
    type = "win11" # Windows Server 2022=win11 (Proxmox)
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  # --- Disk - OS (C:)  ---------------------------------------------------------
  #  Inherited from template; may need resize

  disk {
    interface    = "scsi0"
    datastore_id = var.datastore
    size         = var.os_disk_size_gb
    file_format  = "raw"
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  # --- Additional disks (scsi1, scsi2, etc) -------------------------------
  dynamic "disk" {
    for_each = var.additional_disks
    content {
      interface    = "scsi${disk.key + 1}"
      datastore_id = var.datastore
      size         = disk.value.size_gb
      file_format  = "raw"
      iothread     = true
      discard      = "on"
      ssd          = true
    }
  }

  # --- Network ---------------------------------------------------------------
  network_device {
    bridge  = var.network_bridge
    model   = "virtio"
    vlan_id = var.vlan_id
  }

  # --- Disk type -------------------------------------------------------------
  scsi_hardware = "virtio-scsi-single"

  # --- Startup  --------------------------------------------------------------
  on_boot = var.start_on_boot

  # --- Timeout --------------------------------------------------------------
  timeout_clone = 1200

  # Ignore changes to the clone block after initial creation ------------------
  # Avoids terraform replacing VM if it detects changes.
  lifecycle {
    ignore_changes = [
      clone,
    ]
  }
}

# First routable IP from guest agent (excludes loopback/APIPA); try returns blank to avoid unclear error
locals {
  discovered_ip = try(
    [
      for ip in flatten(proxmox_virtual_environment_vm.windows_vm.ipv4_addresses) : ip
      if !startswith(ip, "127.") && !startswith(ip, "169.254.")
    ][0],
    ""
  )
}

# =============================================================================
# Bootstrap: set hostname and static IP via WinRM (optional)
# Runs once at creation. Skipped when bootstrap_network is null.
# =============================================================================

resource "terraform_data" "bootstrap" {
  count = var.bootstrap_network != null ? 1 : 0

  lifecycle {
    precondition {
      condition     = local.discovered_ip != ""
      error_message = "No IP detected for ${var.hostname}."
    }
  }

  connection {
    type     = "winrm"
    host     = local.discovered_ip
    user     = var.winrm_user
    password = var.winrm_password
    https    = false
    insecure = true
    timeout  = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -NoProfile -Command New-Item -Path 'C:\\ProgramData\\Infutable\\bootstrap\\terraform' -ItemType Directory -Force"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/bootstrap-network.ps1"
    destination = "C:\\ProgramData\\Infutable\\bootstrap\\terraform\\bootstrap-network.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\\ProgramData\\Infutable\\bootstrap\\terraform\\bootstrap-network.ps1 -IPAddress ${var.bootstrap_network.static_ip} -PrefixLength ${var.bootstrap_network.prefix_length} -Gateway ${var.bootstrap_network.gateway} -DNS ${var.bootstrap_network.dns} -Hostname ${var.hostname}"
    ]
  }
}
