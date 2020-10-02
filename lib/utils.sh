#!/bin/bash

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