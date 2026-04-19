# TLS Setup for the Kubernetes Lab

The lab uses kubeadm-generated TLS certificates for the API server. The certificate is created during `kubeadm init`, and that command determines which hostnames and IPs are valid for the API server certificate.

## Secure Connection with Public Domain

If you have set up the `kubeapi_public_hostname` variable in the lab stack (e.g., to `lab.example.com`), the master.sh script automatically includes this hostname in the API server certificate SANs. This ensures secure connections when accessing the cluster through the public domain, preventing "connection is not secure" errors.

The certificate will include the public domain, allowing reliable access via the NGINX proxy across multiple masters without certificate mismatches.

## Workaround for Insecure Access

If you haven't set up the `kubeapi_public_hostname` variable and prefer not to configure it, you can bypass TLS verification when connecting to the cluster using the `--insecure-skip-tls-verify=true` flag with `kubectl`. For example:

```bash
kubectl --insecure-skip-tls-verify=true get nodes
```

This allows access without setting up the public hostname, but note that it disables TLS verification, making the connection less secure.

## Manual Certificate Update

If needed, you can manually add additional SANs to the certificate by modifying the `kubeadm init` command to include `--apiserver-cert-extra-sans=your-domain.com`. However, the automated setup via `kubeapi_public_hostname` variable handles this for you.

For dashboard and browser access, the safest pattern is to keep access local: use `kubectl proxy` or port forwarding from your workstation rather than exposing the API server or dashboard directly on the public internet.
