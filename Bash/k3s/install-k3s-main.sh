#!/bin/bash

# Update system and install Docker if not installed
echo "Installing Docker..."
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Install k3s server (master node)
echo "Installing k3s master..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--docker" sh -

# Wait for k3s to initialize
sleep 5

# Output the node token for worker nodes
echo "K3S_NODE_TOKEN:"
sudo cat /var/lib/rancher/k3s/server/node-token

# Get the master node's IP address (for worker node to join)
echo "Master node IP address:"
hostname -I
