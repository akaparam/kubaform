#!/bin/bash
# Update packages
yum update -y

# Install nginx
yum install -y nginx

# Start nginx service
systemctl start nginx

# Enable nginx to start on boot
systemctl enable nginx