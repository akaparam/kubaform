# Deploying Apps and Accessing Workloads

This repo is built for exploration, so deploying applications is part of the workflow rather than an afterthought.

A good first application to install is the Kubernetes Dashboard. Deploy it with the official manifest:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

Then create an admin ServiceAccount and bind it to the `cluster-admin` role:

```bash
cat <<'EOF' > kubernetes-dashboard-admin.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f kubernetes-dashboard-admin.yaml
```

Fetch the login token:

```bash
kubectl -n kubernetes-dashboard create token admin-user
```
### Connection using local proxy (Preferred)
Start a local proxy:

```bash
kubectl proxy
```

Open the dashboard at:

```text
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

### Alternatively
If you prefer port forwarding instead of `kubectl proxy`:

```bash
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443
```

Then open:

```text
https://localhost:8443
```

This keeps the dashboard behind your local machine and avoids exposing the cluster to the public internet.
