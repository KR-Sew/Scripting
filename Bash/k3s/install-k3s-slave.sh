#!/bin/bash

# Check if master node IP and token are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <MASTER_IP> <K3S_NODE_TOKEN>"
    exit 1
fi

MASTER_IP=$1
NODE_TOKEN=$2

# Update system and install Docker if not installed
echo "Installing Docker..."
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Install k3s worker and join the cluster
echo "Joining k3s cluster as a worker node..."
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$NODE_TOKEN INSTALL_K3S_EXEC="--docker" sh -

# Wait for k3s to initialize
sleep 5

# Check if the worker has joined the cluster
echo "Worker node has joined the cluster. Checking status..."
sudo kubectl get nodes
