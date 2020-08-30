#!/bin/bash

# Populate environment variables
cd "${0%/*}"
source .env

# Destroy K8s cluster on the remove server
cd ${ROOT_DIR}/scripts/create-k8s-cluster/terraform
terraform destroy -auto-approve 

# Destroy the template VM on the remote server
# ssh ${PROXMOX_USER}@${PROXMOX_HOST} "qm destroy ${TEMPLATE_VM_ID} --purge"