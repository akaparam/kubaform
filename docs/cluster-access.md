# Connecting and Setting Up the Cluster

The lab is designed so you can connect through the NGINX jump host. The NGINX instance is the access point for the cluster and makes the control plane easier to reach.

To connect to a master or worker node, use SSH with the jump host option:

```bash
ssh -J ec2-user@lab.example.com ec2-user@<MASTER_OR_WORKER_IP>
```

Once connected, check that NGINX is proxying the Kubernetes API server on port `6443` and that the API server is reachable from the primary master.

Then pull the kubeconfig from the control plane node to your local machine. The example path used in this lab is `~/.kube/kubaform.yaml`.

```bash
scp -J ec2-user@lab.example.com \
  ec2-user@10.1.2.11:/home/ec2-user/.kube/config \
  ~/.kube/kubaform.yaml
```

Update the cluster endpoint in the kubeconfig so it points to the public domain:

```bash
kubectl config set-cluster kubernetes \
  --kubeconfig ~/.kube/kubaform.yaml \
  --server=https://lab.example.com:6443
```

Verify the connection:

```bash
KUBECONFIG=~/.kube/kubaform.yaml kubectl get nodes
KUBECONFIG=~/.kube/kubaform.yaml kubectl get ns
```

This flow lets you manage the cluster from your workstation while keeping the operational access path clearly defined.
