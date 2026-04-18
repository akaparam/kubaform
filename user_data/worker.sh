#!/bin/bash

set -Eeuo pipefail

PRIMARY_MASTER_IP="__PRIMARY_MASTER_IP__"
JOIN_PORT="8080"
WORKER_JOIN_URL="http://${PRIMARY_MASTER_IP}:${JOIN_PORT}/join-worker.sh"
LOG_FILE="/var/log/kubaform-worker.log"

exec > >(tee -a "${LOG_FILE}" | logger -t kubaform-worker -s 2>/dev/console) 2>&1

configure_host_prereqs() {
  modprobe overlay
  modprobe br_netfilter

  cat > /etc/modules-load.d/kubernetes.conf <<'EOF'
overlay
br_netfilter
EOF

  cat > /etc/sysctl.d/kubernetes.conf <<'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

  sysctl --system

  swapoff -a
  sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
}

configure_kubernetes_repo() {
  local version
  local versions=("v1.34" "v1.33" "v1.32" "v1.31" "v1.30")

  for version in "${versions[@]}"; do
    cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${version}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${version}/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

    if dnf --disablerepo="*" --enablerepo="kubernetes" makecache -y >/dev/null 2>&1; then
      echo "Using Kubernetes repo ${version}"
      return
    fi
  done

  echo "Failed to configure Kubernetes package repository."
  exit 1
}

install_dependencies() {
  dnf install -y \
    containerd \
    ca-certificates \
    conntrack-tools \
    iproute-tc \
    socat

  configure_kubernetes_repo
  dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

  mkdir -p /etc/containerd
  containerd config default > /etc/containerd/config.toml
  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

  systemctl enable --now containerd
  systemctl enable kubelet
}

wait_for_worker_join_script() {
  local target attempt max_attempts
  target="/tmp/join-worker.sh"
  max_attempts=120

  for ((attempt = 1; attempt <= max_attempts; attempt++)); do
    if curl -fsSL "${WORKER_JOIN_URL}" -o "${target}"; then
      chmod +x "${target}"
      return
    fi

    echo "Waiting for primary master to publish worker join script (${attempt}/${max_attempts})..."
    sleep 10
  done

  echo "Timed out waiting for worker join script at ${WORKER_JOIN_URL}"
  exit 1
}

join_cluster() {
  if [[ -f /etc/kubernetes/kubelet.conf ]]; then
    echo "Node already joined to a cluster. Skipping kubeadm join."
    return
  fi

  wait_for_worker_join_script
  /tmp/join-worker.sh
}

main() {
  if ! command -v dnf >/dev/null 2>&1; then
    echo "This script currently supports Amazon Linux 2023 (dnf)."
    exit 1
  fi

  configure_host_prereqs
  install_dependencies
  join_cluster

  echo "Worker bootstrap flow completed"
}

main
