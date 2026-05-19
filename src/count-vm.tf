locals {
  public_ssh_key = file("~/.ssh/id_rsa.pub")
}

# Создание web-1 и web-2
resource "yandex_compute_instance" "web" {
  count = 2
  
  name        = "web-${count.index + 1}"
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

  network_interface {
    subnet_id          = yandex_vpc_subnet.default.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.public_ssh_key}"
    hostname = "web-${count.index + 1}"
  }

  depends_on = [
    yandex_compute_instance.db-vm
  ]
}