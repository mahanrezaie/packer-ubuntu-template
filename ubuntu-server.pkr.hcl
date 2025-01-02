# Variables
variable "proxmox_api_url" {
    type = string
    
}

variable "proxmox_api_token_id" {
    type = string
    sensitive = true 
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}
variable "ssh_password" {
    type = string
    sensitive = true
}

variable "ssh_username" {
    type = string
    sensitive = true
}

packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

#Resource 
source "proxmox-iso" "ubuntu-server-noble"{

    #Connection settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    
    insecure_skip_tls_verify = true

    boot_iso {
        #VM OS settings
        iso_file = "hdd:iso/ubuntu-24.04-live-server-amd64.iso"
        iso_storage_pool = "hdd"
        
    }


    #VM settings
    node = "asus"
    vm_id = "3000"
    vm_name = "ubuntu-server-docker"
    template_description = "Ubuntu Server Noble Image"

    #VM system settings
    qemu_agent = true 
    scsi_controller = "virtio-scsi-single"

    disks {
        disk_size = "45G"
        format = "raw"
        storage_pool = "local-lvm"
    }

    cores = "2"
    memory = "2048"
   
     network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = false
    } 

    cloud_init              = true
    cloud_init_storage_pool = "hdd"
   

    boot_command = [
       "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]

    # boot_command = [
    # "<esc><wait>",
    # "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    # "<f10><wait>"
# ]

    boot = "c"
    boot_wait = "10s"
    communicator = "ssh"
    http_directory = "./http"

    ssh_username = "${var.ssh_username}"
    ssh_password = "${var.ssh_password}"
    ssh_timeout = "60m"

}

build {

    name = "ubuntu-server-noble"
    sources = ["source.proxmox-iso.ubuntu-server-noble"]
    
       
    provisioner "shell" {
        inline = [
            "rm /etc/ssh/ssh_host_*",
            "truncate -s 0 /etc/machine-id",
            "apt -y autoremove --purge",
            "apt -y clean",
            "apt -y autoclean",
            "cloud-init clean",
            "rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sync",
           
        ]
    }

    provisioner "shell" {
        inline = [ "resolvectl dns 2 178.22.122.100" ]
    }

    provisioner "shell" {
        script = "./scripts/get-docker.sh"
        pause_before = "10s"
    }

   }








