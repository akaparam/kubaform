#!/bin/bash

set -e

# Install NGINX
if grep -q "Amazon Linux 2" /etc/os-release; then
    sudo amazon-linux-extras enable nginx1 || true
    sudo yum clean metadata
    sudo yum install -y nginx
else
    sudo dnf install -y nginx
fi

# Install stream module (auto-loads module)
if command -v dnf &> /dev/null; then
    sudo dnf install -y nginx-mod-stream
else
    sudo yum install -y nginx-mod-stream
fi

# Create stream config
sudo tee /etc/nginx/stream.conf > /dev/null <<EOF
stream {
    upstream lab {
        server 10.1.2.11:6443;
        server 10.1.3.11:6443;
    }

    server {
        listen 6443;
        proxy_pass lab;
    }
}
EOF

# Include stream config
if ! grep -q "stream.conf" /etc/nginx/nginx.conf; then
    sudo sed -i '/^events {/i include /etc/nginx/stream.conf;' /etc/nginx/nginx.conf
fi

# Open firewall (if enabled)
if systemctl is-active --quiet firewalld; then
    sudo firewall-cmd --permanent --add-port=6443/tcp
    sudo firewall-cmd --reload
fi

# Start NGINX
sudo systemctl enable nginx
sudo nginx -t
sudo systemctl restart nginx

echo "NGINX stream proxy configured on port 6443 (upstream: lab)"