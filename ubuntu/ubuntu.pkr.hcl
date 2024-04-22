packer {
    required_plugins {
        qemu = {
            version = "~> 1"
            source = "github.com/hashicorp/qemu"
        }
        ansible = {
            version = "~> 1"
            source = "github.com/hashicorp/ansible"
        }
    }
}

variable "vm_template_name" {
    type = string
    default = "ubuntu-22.04"
}

variable "ubuntu_iso_file" {
    type = string
    default = "ubuntu-22.04.4-live-server-amd64.iso"
}

source "qemu" "custom_image" {
    boot_command = [
        "<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait>",
        "e<wait>",
        "<down><down><down><end>",
        " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
        "<f10>"
    ]
    boot_wait = "5s"
    http_directory = "http"
    iso_url = "https://releases.ubuntu.com/22.04.4/${var.ubuntu_iso_file}"
    iso_checksum = "45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
    memory = 4096
    ssh_password = "ubuntu"
    ssh_username = "ubuntu"
    ssh_timeout = "20m"
    shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
    headless = false
    accelerator = "kvm"
    format = "qcow2"
    disk_size = "30G"
    cpus = 2
    qemuargs = [
        ["-bios", "/usr/share/OVMF/OVMF_CODE.fd"]
    ]
    vm_name = "${var.vm_template_name}"
}

build {
    sources = [ "source.qemu.custom_image" ]
    provisioner "shell" {
        inline = [ "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 1; done" ]
    }
    provisioner "ansible" {
        playbook_file = "./playbook.yml"
    }
}