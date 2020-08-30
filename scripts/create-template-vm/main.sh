#!/bin/bash

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config

# https://nickcharlton.net/posts/automating-ubuntu-2004-installs-with-packer.html
# https://imagineer.in/blog/packer-build-for-ubuntu-20-04/
# https://github.com/hashicorp/packer/issues/9115
# *https://medium.com/@tlhakhan/ubuntu-server-20-04-autoinstall-2e5f772b655a
# *https://www.aerialls.io/posts/ubuntu-server-2004-image-packer-subiquity-for-proxmox/
# https://jaylacroix.com/fixing-ubuntu-18-04-virtual-machines-that-fight-over-the-same-ip-address/
# * https://yetiops.net/posts/proxmox-terraform-cloudinit-saltstack-prometheus/#define-an-instance

# Populate environment variables
cd "${0%/*}"
source ../.env

###############################################################################
# PREPARE SCRIPT VARIABLES
###############################################################################

declare -r PACKER_VERSION=1.6.2
declare -r PACKER_BINFILE=packer_${PACKER_VERSION}_linux_amd64.zip
declare -r PACKER_URL=https://releases.hashicorp.com/packer/${PACKER_VERSION}/${PACKER_BINFILE}
declare -r ISO_PATH=/var/lib/vz/template/iso
declare -r ISO_FILE=ubuntu-20.04.1-live-server-amd64.iso
declare -r ISO_URL=https://releases.ubuntu.com/20.04/${ISO_FILE}
declare -r PACKER_FILE=ubuntu.json

###############################################################################
# INSTALL PACKER
###############################################################################

# Install packer precompiled binary
if [ ! -f "/usr/local/bin/packer" ]; then
    wget ${PACKER_URL}
    unzip ${PACKER_BINFILE} -d /usr/local/bin
    rm ${PACKER_BINFILE}
fi

###############################################################################
# CREATE TEMPLATE VM
###############################################################################

# Download the base ISO if it doesn't exist
if [ ! -f "${ISO_PATH}/${ISO_FILE}" ]; then
    wget ${ISO_URL}
    mv ${ISO_FILE} ${ISO_PATH}
fi

# Create the Proxmox template VM
# NOTE: Prefix packer command with `PACKER_LOG=1 PACKER_LOG_PATH=packer.log` for debugging
qm status ${TEMPLATE_VM_ID}
if [ $? -ne 0 ]; then
    cd ${SERVER_ROOT_DIR}/create-template-vm/packer
    packer build ${PACKER_FILE}
fi
