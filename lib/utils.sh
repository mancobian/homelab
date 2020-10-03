#!/bin/bash
# NOTE: Requires that environment variable are sourced before being called.

function prep_proxmox_server() {
    # Create target directories on Proxmox server
    ssh ${PROXMOX_USER}@${PROXMOX_HOST} "mkdir -p ${REMOTE_CONFIG_DIR} ${REMOTE_INSTALL_DIR}"

    # Copy config files to the Proxmox server
    rsync --exclude .git \
        -arvzP ${CONFIG_DIR}/ \
        ${PROXMOX_USER}@${PROXMOX_HOST}:${REMOTE_CONFIG_DIR}

    # Copy homelab files to the Proxmox server
    rsync -arvzP --rsh=ssh ${INSTALL_DIR}/ \
        ${CI_SSH_KEY_PATH}/${CI_PUBLIC_KEY_FILE} \
        ${CI_SSH_KEY_PATH}/${CI_PRIVATE_KEY_FILE} \
        ${PROXMOX_USER}@${PROXMOX_HOST}:${REMOTE_INSTALL_DIR}
}

function get_k8s_master_hostname() {
    for file in ${CONFIG_DIR}/proxmox/*.cfg; do
        source ${file}
        case "${ROLE}" in
            master)
                MASTER=${HOSTNAME}
                ;;
            *)
                ;; 
        esac
    done
    echo $MASTER
}