locals {
  webservers = [
    for i, vm in yandex_compute_instance.web : {
      name        = vm.name
      external_ip = vm.network_interface[0].nat_ip_address
      fqdn        = vm.fqdn
    }
  ]
  
  databases = [
    for name, vm in yandex_compute_instance["db-vm"] : {
      name        = vm.name
      external_ip = vm.network_interface[0].nat_ip_address
      fqdn        = vm.fqdn
    }
  ]
  
  storage = [
    {
      name        = yandex_compute_instance.storage.name
      external_ip = yandex_compute_instance.storage.network_interface[0].nat_ip_address
      fqdn        = yandex_compute_instance.storage.fqdn
    }
  ]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"
  content = templatefile("${path.module}/inventory.tmpl", {
    webservers = local.webservers
    databases  = local.databases
    storage    = local.storage
  })
  
  depends_on = [
    yandex_compute_instance.web,
    yandex_compute_instance.db-vm,
    yandex_compute_instance.storage
  ]
}