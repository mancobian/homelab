# Overview
Create a multi-node Kubernetes cluster on a single server in a [Proxmox Virtual Environment](https://www.proxmox.com).

# Server Specs
- CPU: 32 x Intel(R) Xeon(R) CPU E5-2640 v3 @ 2.60GHz (2 Sockets)
- RAM: 128 GB
- Disk 
  - local-zfs 
    - Content: Disk Image, Container
    - Type: ZFS, Mirror
    - Size: 500 GB (x2)
  - data
    - Content: Disk Image, Container
    - Type: ZFS, Mirror
    - Size: 2 TB (x2)

# K8s Cluster Specs
- Master (x1)
  - CPU: 4 cores
  - RAM: 32 GB
- Worker (x3)
  - CPU: 2 cores
  - RAM: 8 GB
- Data (x1)
  - CPU: 4 cores
  - RAM: 16 GB

# Commands
- `make install` - Install `homelab` 
- `make uninstall` - Remove `homelab` 
- `homelab setup` - Setup `homelab` resources
- `homelab teardown` - Teardown `homelab` resources

# References
- The Engineer's Workshop, ["LVM, Thin Provisioning, and Monitoring Storage Use: A Case Study"](https://engineerworkshop.com/blog/lvm-thin-provisioning-and-monitoring-storage-use-a-case-study/)
- YouTube, ["Creating a template in Proxmox Virtual Environment with cloud-init support"](https://www.youtube.com/watch?v=8qwnXd1yRK4&ab_channel=LearnLinuxTV) - cloud-init networking workaround
- LinkedIn, ["Lost SSH Key? Cloud-init is the answer"](https://www.linkedin.com/pulse/lost-ssh-key-cloud-init-answer-himanshoo-wadhwa/)
- cloudinit.co, ["How to Set Up SSH Keys on Ubuntu 18.04"](https://cloudinit.co/how-to-set-up-ssh-keys-on-ubuntu-18-04/)
- learnk8s.com, ["Architecting Kubernetes clusters — choosing a worker node size"](https://learnk8s.io/kubernetes-node-size)
- yetiops.net, ["Using Terraform and Cloud-Init to deploy and automatically monitor Proxmox instances"](https://yetiops.net/posts/proxmox-terraform-cloudinit-saltstack-prometheus/#creating-a-template)
- freedesktop.org, ["XDG Base Directory Specification"](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)