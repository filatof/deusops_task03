resource "proxmox_virtual_environment_vm" "k8s_ubuntu" {
  for_each  = var.homelab_servers

  name      = each.key
  node_name = "pve"
  vm_id = each.value.vm_id

  description = "Ubuntu servers managed by Terraform"
  tags        = ["task03", "deusops", "DEV"]

  on_boot         = true
  stop_on_destroy = true

  agent {
    enabled = true
  }

  clone {
    vm_id = "9002"
    full  = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    file_format  = "raw"
    size         = 80
  }

  initialization {
    interface    = "scsi2"
    datastore_id = "local-zfs"

    user_account {
      username = var.user_name
      password = var.user_passwd
      keys     = [var.ssh_public_key]
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = "10.10.0.1"
      }
    }

    dns {
      servers = ["192.168.1.4", "8.8.4.4"]
    }
  }

  network_device {
    bridge = "vmbr1"
  }

  operating_system {
    type = "l26"
  }
}