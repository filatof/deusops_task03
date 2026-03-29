resource "yandex_iam_service_account" "bastion_sa" {
  name      = "bastion-sa"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "bastion_cert_downloader" {
  folder_id = var.folder_id
  role      = "certificate-manager.certificates.downloader"
  member    = "serviceAccount:${yandex_iam_service_account.bastion_sa.id}"
}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  service_account_id = yandex_iam_service_account.bastion_sa.id

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_bastion.id
  }

  network_interface {
    index     = 1
    subnet_id = yandex_vpc_subnet.my_subnet.id
    ip_address = "10.10.1.5"
    nat = "true"
  }

  metadata = {
    user-data = "${file("./cloudinit.d/01_bastion.yaml")}"
    serial-port-enable     = "true"
    enable-monitoring-agent = "true"
  }
}

//
// Create a new Compute Disk.
//
resource "yandex_compute_image" "ubuntu_2204_bastion" {
  source_family = "ubuntu-2204-lts-oslogin"
}


resource "yandex_compute_disk" "disk_bastion" {
  zone        = "ru-central1-a"
  name     = "boot-disk-bastion"
  type     = "network-hdd"
  size     = "10"
  image_id = yandex_compute_image.ubuntu_2204_bastion.id
  labels = {
    environment = "bastion"
  }
}