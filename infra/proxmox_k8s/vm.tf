resource "proxmox_virtual_environment_vm" "k8s_talos" {
  for_each  = var.k8s_nodes

  name      = each.key
  node_name = "pve"
  vm_id = each.value.vm_id

  description = "K8s Talos node managed by Terraform"
  tags        = ["k8s", "Talos", "victoria-metrics"]

  on_boot         = true
  stop_on_destroy = true

  agent {
    enabled = true
  }

  clone {
    vm_id = "9009"
    full  = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    file_format  = "raw"
    size         = 30
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi1"
    file_format  = "raw"
    size         = 50
    discard      = "on"
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
      servers = ["8.8.8.8", "8.8.4.4"]
    }
  }

  network_device {
    bridge = "vmbr1"
    mtu    = 1380
  }

  operating_system {
    type = "l26"
  }
}