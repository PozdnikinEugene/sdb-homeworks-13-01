output "web_vm_ips" {
  description = "External IP addresses of web VMs"
  value = {
    for i, vm in yandex_compute_instance.web :
    vm.name => vm.network_interface[0].nat_ip_address
  }
}

output "db_vm_ips" {
  description = "External IP addresses of database VMs"
  value = {
    for name, vm in yandex_compute_instance.db-vm :
    name => vm.network_interface[0].nat_ip_address
  }
}

output "storage_vm_ip" {
  description = "External IP address of storage VM"
  value       = yandex_compute_instance.storage.network_interface[0].nat_ip_address
}

output "vms_fqdn" {
  description = "FQDN of all created VMs"
  value = {
    web = {
      for vm in yandex_compute_instance.web :
      vm.name => vm.fqdn
    }
    db = {
      for name, vm in yandex_compute_instance.db-vm :
      name => vm.fqdn
    }
    storage = {
      storage = yandex_compute_instance.storage.fqdn
    }
  }
}

output "inventory_file" {
  description = "Path to generated Ansible inventory"
  value       = local_file.ansible_inventory.filename
}