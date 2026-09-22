#!/bin/bash
# 1. Deploy Kong Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/master/deploy/single/all-in-one-dbless.yaml

# 2. Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 3. Add Repos and Deploy Loki & Fluent Bit
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

kubectl create namespace logging
helm install loki grafana/loki --namespace logging
helm install fluent-bit fluent/fluent-bit --namespace logging

echo "Cluster tools installed successfully!"
