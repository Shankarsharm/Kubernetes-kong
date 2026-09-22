#!/bin/bash
# Update system and install dependencies
apt-get update -y
apt-get install -y docker.io curl apt-transport-https conntrack

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Grant the default 'ubuntu' user Docker permissions
usermod -aG docker ubuntu

# Download and install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# Download and install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Start Minikube as the 'ubuntu' user
su - ubuntu -c "minikube start --driver=docker --cpus=2 --memory=6144"
