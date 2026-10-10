output "vm_ip_addresses" {
  description = "IP addresses of all VMs"
  value = {
    for name, vm in proxmox_virtual_environment_vm.ubuntu :
    name => vm.initialization[0].ip_config[0].ipv4[0].address
  }
}