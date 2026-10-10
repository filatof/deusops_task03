resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"
  for_each = var.homelab_servers


  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${each.key}
    timezone: Europe/Moscow
    users:
      - default
      - name: ubuntu
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlPFhFwKepToM3D/5wgUfFsPsv99sZkfUr9gnuhYYr/ fill@MacBookAir.local
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - curl -s https://get.docker.com | bash
      - systemctl enable docker
      - systemctl start docker
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "user-data-cloud-config-${each.key}.yaml"
  }
}