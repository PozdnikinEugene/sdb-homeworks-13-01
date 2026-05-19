locals {
  db_vms_map = {
    for vm in var.each_vm :
    vm.vm_name => vm
  }
}


# Создание ВМ для баз данных с использованием for_each
resource "yandex_compute_instance" "db-vm" {
  for_each = local.db_vms_map

  name        = each.value.vm_name
  platform_id = "standard-v1"
  zone        = var.zone

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = each.value.disk_volume
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${local.public_ssh_key}"
    hostname = each.value.vm_name
  }
}