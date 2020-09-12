#!/bin/bash

function destroy-vms {
    # Destroy K8s nodes
    for file in cfg/*.cfg; do
        source ${file}
        ssh ${PROXMOX_USER}@${PROXMOX_HOST} "qm stop ${VMID}; qm destroy ${VMID} --purge"
    done

    # Destroy template
    ssh ${PROXMOX_USER}@${PROXMOX_HOST} "qm destroy ${TEMPLATE_VMID} --purge; rm /var/lib/vz/snippets/user-data-*.yml"
}

destroy-vms