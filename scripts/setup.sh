#!/bin/bash

# Populate environment variables
cd "${0%/*}"
source .env

# Copy installation files to the remote server
rsync -arvzP --delete \
    ${ROOT_DIR}/scripts/ \
    ${PROXMOX_USER}@${PROXMOX_HOST}:${SERVER_ROOT_DIR}

# Create template VM on the remote server
ssh ${PROXMOX_USER}@${PROXMOX_HOST} "${SERVER_ROOT_DIR}/create-template-vm/main.sh"
 
# Create the K8s cluster on the remote server
# NOTE: `export TF_LOG=trace` to debug; `export TF_LOG=error` to restore
cd ${ROOT_DIR}/scripts/create-k8s-cluster/terraform
terraform init 
terraform plan 
terraform apply -auto-approve 
