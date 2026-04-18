#!/bin/bash

set -Eeuo pipefail

PRIMARY_MASTER_IP="__PRIMARY_MASTER_IP__"
CONTROL_PLANE_ENDPOINT="__CONTROL_PLANE_ENDPOINT__"
POD_NETWORK_CIDR="192.168.0.0/16"
CALICO_MANIFEST_URL="https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/calico.yaml"
JOIN_DIR="/var/lib/kubaform"
JOIN_PORT="8080"
WORKER_JOIN_SCRIPT="${JOIN_DIR}/join-worker.sh"
CONTROL_PLANE_JOIN_SCRIPT="${JOIN_DIR}/join-control-plane.sh"
LOG_FILE="/var/log/kubaform-master.log"

exec > >(tee -a "${LOG_FILE}" | logger -t kubaform-master -s 2>/dev/console) 2>&1

get_local_ipv4() {
  local token local_ip
  token="$(curl -fsSL -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)"

  if [[ -n "${token}" ]]; then
    local_ip="$(curl -fsSL -H "X-aws-ec2-metadata-token: ${token}" \
      "http://169.254.169.254/latest/meta-data/local-ipv4" || true)"
  else
    local_ip="$(curl -fsSL "http://169.254.169.254/latest/meta-data/local-ipv4" || true)"
  fi

  if [[ -z "${local_ip}" ]]; then
    local_ip="$(hostname -I | awk '{print $1}')"
  fi

  echo "${local_ip}"
}

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
    socat \
    python3

  configure_kubernetes_repo
  dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

  mkdir -p /etc/containerd
  containerd config default > /etc/containerd/config.toml
  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

  systemctl enable --now containerd
  systemctl enable kubelet
}

configure_kubectl_access() {
  mkdir -p /root/.kube
  cp -f /etc/kubernetes/admin.conf /root/.kube/config

  if id -u ec2-user >/dev/null 2>&1; then
    mkdir -p /home/ec2-user/.kube
    cp -f /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
    chown -R ec2-user:ec2-user /home/ec2-user/.kube
  fi
}

generate_join_scripts() {
  local worker_join_cmd cert_key
  mkdir -p "${JOIN_DIR}"

  worker_join_cmd="$(kubeadm token create --ttl 0 --print-join-command)"
  cert_key="$(kubeadm init phase upload-certs --upload-certs | grep -E '^[a-f0-9]{64}$' | tail -n 1)"

  if [[ -z "${cert_key}" ]]; then
    echo "Failed to retrieve control plane certificate key."
    exit 1
  fi

  cat > "${WORKER_JOIN_SCRIPT}" <<EOF
#!/bin/bash
set -euo pipefail
${worker_join_cmd} "\$@"
EOF

  cat > "${CONTROL_PLANE_JOIN_SCRIPT}" <<EOF
#!/bin/bash
set -euo pipefail
${worker_join_cmd} --control-plane --certificate-key ${cert_key} "\$@"
EOF

  chmod 750 "${WORKER_JOIN_SCRIPT}" "${CONTROL_PLANE_JOIN_SCRIPT}"
}

enable_join_script_server() {
  cat > /etc/systemd/system/kubaform-join-server.service <<EOF
[Unit]
Description=Serve kubeadm join scripts for KubaForm nodes
After=network.target

[Service]
Type=simple
WorkingDirectory=${JOIN_DIR}
ExecStart=/usr/bin/python3 -m http.server ${JOIN_PORT} --bind 0.0.0.0 --directory ${JOIN_DIR}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now kubaform-join-server.service
}

install_network_plugin() {
  if ! kubectl --kubeconfig=/etc/kubernetes/admin.conf get daemonset calico-node -n kube-system >/dev/null 2>&1; then
    kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f "${CALICO_MANIFEST_URL}" || \
      echo "Calico installation failed. Install a CNI plugin manually."
  fi
}

wait_for_control_plane_join_script() {
  local url target attempt max_attempts
  url="http://${PRIMARY_MASTER_IP}:${JOIN_PORT}/join-control-plane.sh"
  target="/tmp/join-control-plane.sh"
  max_attempts=120

  for ((attempt = 1; attempt <= max_attempts; attempt++)); do
    if curl -fsSL "${url}" -o "${target}"; then
      chmod +x "${target}"
      return
    fi

    echo "Waiting for primary master to publish control-plane join script (${attempt}/${max_attempts})..."
    sleep 10
  done

  echo "Timed out waiting for control-plane join script at ${url}"
  exit 1
}

bootstrap_primary_master() {
  local local_ip="$1"

  if [[ ! -f /etc/kubernetes/admin.conf ]]; then
    kubeadm init \
      --apiserver-advertise-address "${local_ip}" \
      --control-plane-endpoint "${CONTROL_PLANE_ENDPOINT}" \
      --pod-network-cidr "${POD_NETWORK_CIDR}" \
      --upload-certs
  fi

  configure_kubectl_access
  generate_join_scripts
  enable_join_script_server
  install_network_plugin
}

join_secondary_control_plane() {
  local local_ip="$1"

  if [[ -f /etc/kubernetes/kubelet.conf ]]; then
    echo "Node already joined to a cluster. Skipping kubeadm join."
    return
  fi

  wait_for_control_plane_join_script
  /tmp/join-control-plane.sh --apiserver-advertise-address "${local_ip}"
  configure_kubectl_access
}

main() {
  if ! command -v dnf >/dev/null 2>&1; then
    echo "This script currently supports Amazon Linux 2023 (dnf)."
    exit 1
  fi

  local local_ip

  configure_host_prereqs
  install_dependencies
  local_ip="$(get_local_ipv4)"

  if [[ "${local_ip}" == "${PRIMARY_MASTER_IP}" ]]; then
    bootstrap_primary_master "${local_ip}"
  else
    join_secondary_control_plane "${local_ip}"
  fi

  echo "Master bootstrap flow completed on ${local_ip}"
}

main
