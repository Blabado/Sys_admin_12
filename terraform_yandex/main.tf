resource "yandex_compute_disk" "boot-disk" {
  for_each = var.virtual_machines
  name     = each.value["disk_name"]
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = each.value["disk"]
  image_id = each.value["template"]
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "virtual_machine" {
  for_each = var.virtual_machines
  name     = each.value["vm_name"]

  resources {
    cores  = each.value["vm_cpu"]
    memory = each.value["ram"]
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk[each.key].id
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    nat        = true
    ip_address = each.value["ip_address"]
  }

  metadata = {
    ssh-keys  = "sys_admin:${file("~/Sys_admin_12/ssh_cloud/id_ed25519.pub")}"
    user-data = <<EOF
#cloud-config
users:
  - name: sys_admin
    shell: /bin/bash
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ${file("~/Sys_admin_12/ssh_cloud/id_ed25519.pub")}
EOF
  }
} 
