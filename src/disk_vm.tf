resource "yandex_compute_disk" "storage_disk" {
  count = 3
  
  name     = "storage-disk-${count.index + 1}"
  type     = "network-hdd"
  zone     = var.zone
  size     = 1
  
  labels = {
    environment = "storage"
    disk-number = "${count.index + 1}"
  }
}


resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = "standard-v1"
  zone        = var.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.storage_disk[*].id
    
    content {
      disk_id = secondary_disk.value
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${local.public_ssh_key}"
    hostname = "storage"
  }

  depends_on = [
    yandex_compute_disk.storage_disk
  ]
}