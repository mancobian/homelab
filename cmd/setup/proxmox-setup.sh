#!/bin/bash
# NOTE: Requires that environment variable are sourced before being called.

function create-template-vm {
    if [ ! -f /tmp/${UBUNTU_RELEASE}.img ]; then
        wget -O /tmp/${UBUNTU_RELEASE}.img https://cloud-images.ubuntu.com/${UBUNTU_RELEASE}/current/${UBUNTU_RELEASE}-server-cloudimg-amd64.img
    fi

    qm status ${TEMPLATE_VMID}
    if [ $? -ne 0 ]; then
        qm create ${TEMPLATE_VMID} --memory 2048 --net0 virtio,bridge=vmbr0 --agent 1 --name ubuntu
        # import the downloaded disk to local storage
        qm importdisk ${TEMPLATE_VMID} /tmp/${UBUNTU_RELEASE}.img data
        # finally attach the new disk to the VM as scsi drive
        qm set ${TEMPLATE_VMID} --scsihw virtio-scsi-pci --scsi0 data:vm-${TEMPLATE_VMID}-disk-0,discard=on,iothread=1,ssd=1
        # attach cloud-init data as cdrom drive
        qm set ${TEMPLATE_VMID} --ide2 data:cloudinit
        # boot from disk only; faster due to skipping bootable cdrom check
        qm set ${TEMPLATE_VMID} --boot c --bootdisk scsi0
        # configure serial console and use it for display; cloud-init images rely on this
        qm set ${TEMPLATE_VMID} --serial0 socket --vga serial0
        # convert vm into a template
        qm template ${TEMPLATE_VMID}
    fi
}

function create-k8s-nodes {
    for file in ${REMOTE_CONFIG_DIR}/proxmox/*.cfg; do
        source ${file}
        qm status ${VMID}
        if [ $? -ne 0 ]; then
            export CI_PUBLIC_KEY=`cat ${REMOTE_INSTALL_DIR}/${CI_PUBLIC_KEY_FILE}`
            export CI_PRIVATE_KEY=`cat ${REMOTE_INSTALL_DIR}/${CI_PRIVATE_KEY_FILE} | sed 's/^/      /'`
            envsubst < ${REMOTE_INSTALL_DIR}/cmd/setup/user-data.yml > /var/lib/vz/snippets/user-data-${VMID}.yml
            qm clone ${TEMPLATE_VMID} ${VMID} \
                --full false \
                --name ${HOSTNAME}; 
            qm set ${VMID} \
                --ciuser "${CI_USER}" \
                --cipassword "${CI_PASSWORD}" \
                --citype "nocloud" \
                --nameserver "${NAME_SERVER}" \
                --searchdomain "${SEARCH_DOMAIN}" \
                --onboot 1 \
                --ipconfig0 "ip=dhcp" \
                --cicustom "user=local:snippets/user-data-${VMID}.yml" \
                --cores ${CORES} \
                --memory ${MEMORY}; 
            qm resize ${VMID} scsi0 ${DISK}; 
            qm start ${VMID}; 
        fi
    done
}

function wait-for-guest-agents {
    for file in ${REMOTE_CONFIG_DIR}/proxmox/*.cfg; do
        source ${file}
        echo "Waiting for guest agent on VM ID ${VMID}..."
        until qm guest exec ${VMID} ping; do
            sleep 1
        done
    done
}

function create-k8s-cluster {
    local MASTER=""
    local NODES=()

    for file in ${REMOTE_CONFIG_DIR}/proxmox/*.cfg; do
        source ${file}
        case "${ROLE}" in
            data)
                NODES+=(${HOSTNAME})
                ;;
            worker)
                NODES+=(${HOSTNAME})
                ;;
            master)
                MASTER=${HOSTNAME}
                ;;
            *)
                ;; 
        esac
    done

    # Join K8s worker nodes to K8s master
    ssh-keygen -f ~/.ssh/known_hosts -R ${MASTER}.${SEARCH_DOMAIN}
    for NODE in ${NODES[@]}; do
        ssh-keygen -f ~/.ssh/known_hosts -R ${NODE}.${SEARCH_DOMAIN}
        ssh -qo 'StrictHostKeyChecking no' ${CI_USER}@${NODE}.${SEARCH_DOMAIN} -- sudo $(ssh -o 'StrictHostKeyChecking no' ${CI_USER}@${MASTER}.${SEARCH_DOMAIN} sudo microk8s add-node | grep 'Join node with' | sed 's/Join node with: //' | tr -d '\n')
    done
}

create-template-vm
create-k8s-nodes
wait-for-guest-agents
create-k8s-cluster