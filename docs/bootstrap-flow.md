# Master and Worker Bootstrap Flow

The heart of the lab lives in `kubaform/lab/user_data/master.sh` and `kubaform/lab/user_data/worker.sh`. These scripts are what each instance runs when it first boots.

`master.sh` is used by the primary master and by additional control-plane nodes. On the first master, the script:

- installs `containerd`, `kubelet`, `kubeadm`, and `kubectl` on Amazon Linux 2023,
- configures the kernel modules and `sysctl` settings needed for Kubernetes,
- disables swap,
- initializes the control plane with `kubeadm init`, and
- generates join scripts for workers and control plane nodes.

The join scripts are written into `/var/lib/kubaform` and served on port `8080`. That means secondary masters and workers can fetch the exact command they need to join the cluster, which keeps the process simple and repeatable.

`worker.sh` prepares worker nodes the same way the master script prepares control plane nodes. Once the node has the Kubernetes packages installed, it waits for the worker join script to appear and then runs it.

The join process is intentionally safe to rerun. If `/etc/kubernetes/kubelet.conf` already exists, the worker script assumes the node is already joined and skips the join step.

This design keeps the cluster bootstrapping flow explicit and easy to inspect in the repository.
