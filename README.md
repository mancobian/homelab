# Overview
This repo is intended to automate the creation of a multi-node Kubernetes cluster in a [Proxmox Virtual Environment](https://www.proxmox.com).

# Setup
- Configure passwordless SSH from your dev box to the Proxmox server

# Scripts
- `./scripts/setup.sh` - Create a K8s cluster
- `./scripts/teardown.sh` - Destroys the K8s cluster

# Todo
- Preprocess the cloud-init user-data file to support use of envvars
