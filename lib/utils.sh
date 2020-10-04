#!/bin/bash
# NOTE: Requires that environment variable are sourced before being called.

function prep_k8s_master() {
    # Get K8s master
    K8S_MASTER="$(get_k8s_master_hostname)"

    # Create target directories on Proxmox server
    ssh ${CI_USER}@${K8S_MASTER}.${SEARCH_DOMAIN} "mkdir -p ${REMOTE_CONFIG_DIR} ${REMOTE_INSTALL_DIR}"

    # Copy k8s files to the remote server
    rsync -e "ssh -o StrictHostKeyChecking=no" \
        --delete -aqrvzP ${CONFIG_DIR}/ \
        ${CI_USER}@${K8S_MASTER}.${SEARCH_DOMAIN}:${REMOTE_CONFIG_DIR}

    # Copy environment file to the remote server
    rsync -e "ssh -o StrictHostKeyChecking=no" \
        --delete -aqrvzP ${INSTALL_DIR}/.env \
        ${CI_USER}@${K8S_MASTER}.${SEARCH_DOMAIN}:${REMOTE_INSTALL_DIR}
}

function prep_proxmox_server() {
    # Create target directories on Proxmox server
    ssh ${PROXMOX_USER}@${PROXMOX_HOST}.${SEARCH_DOMAIN} "mkdir -p ${REMOTE_CONFIG_DIR} ${REMOTE_INSTALL_DIR}"

    # Copy config files to the Proxmox server
    rsync --exclude .git \
        --delete -aqrvzP ${CONFIG_DIR}/ \
        ${PROXMOX_USER}@${PROXMOX_HOST}.${SEARCH_DOMAIN}:${REMOTE_CONFIG_DIR}

    # Copy homelab files to the Proxmox server
    rsync --delete -aqrvzP ${INSTALL_DIR}/ \
        ${CI_SSH_KEY_PATH}/${CI_PUBLIC_KEY_FILE} \
        ${CI_SSH_KEY_PATH}/${CI_PRIVATE_KEY_FILE} \
        ${PROXMOX_USER}@${PROXMOX_HOST}.${SEARCH_DOMAIN}:${REMOTE_INSTALL_DIR}
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