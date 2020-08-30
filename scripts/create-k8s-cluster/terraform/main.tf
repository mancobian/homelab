variable "TEMPLATE_VM_NAME" { type=string }
variable "HL_NODE" { type=string }
variable "HL_NODE_FQDN" { type=string }
variable "HL_DOMAIN" { type=string }
variable "HL_NAMESERVER" { type=string }
variable "CI_USER" { type=string }
variable "CI_PASSWORD" { type=string }
variable "PROXMOX_SSH_PRIVATE_KEY" { type=string }
variable "PROXMOX_STORAGE_SNIPPETS" { type=string }
variable "PROXMOX_STORAGE_SNIPPETS_PATH" { type=string }
variable "PROXMOX_STORAGE_VM" { type=string }

# Source the Cloud Init Config file
data "template_file" "ci_1" {
  template = "${file("${path.module}/ci.tmpl")}"
  vars = {
    hostname = "tf-1"
    domain = var.HL_DOMAIN
  }
}

# Create a local copy of the file, to transfer to Proxmox
resource "local_file" "ci_1" {
  content   = data.template_file.ci_1.rendered
  filename  = "${path.module}/files/cicustom_1.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "ci_1" {
  connection {
    type = "ssh"
    user = "root"
    private_key = file(var.PROXMOX_SSH_PRIVATE_KEY)
    host = var.HL_NODE_FQDN
  }

  provisioner "file" {
    source       = local_file.ci_1.filename
    destination  = "${var.PROXMOX_STORAGE_SNIPPETS_PATH}/cicustom_1.yml"
  }
}

provider "proxmox" {
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "terraform_test" {
  depends_on = [
    null_resource.ci_1
  ]

  name = "tf-1"
  agent = 1
  target_node = var.HL_NODE
  clone = var.TEMPLATE_VM_NAME
  os_type = "cloud-init"
  cores = 4
  sockets = 1
  memory = "4096"
  ciuser = var.CI_USER
  cipassword = var.CI_PASSWORD
  searchdomain = var.HL_DOMAIN
  nameserver = var.HL_NAMESERVER
  ipconfig0 = "ip=dhcp,ip6=dhcp"
  bootdisk = "scsi0"
  scsihw = "virtio-scsi-pci"
  cicustom = "user=${var.PROXMOX_STORAGE_SNIPPETS}:snippets/cicustom_1.yml"

  disk {
    id = 0
    size = 25
    type = "scsi"
    storage_type = "lvmthin"
    storage = var.PROXMOX_STORAGE_VM
  }

  network {
    id = 0
    model = "virtio"
    bridge = "vmbr0"
  }

  # Ignore changes to the network
  # MAC address is generated on every apply, causing TF to think this needs to be rebuilt on every apply
  lifecycle {
    ignore_changes  = [
      network,
    ]
  }
}
