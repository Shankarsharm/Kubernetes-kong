# E-Commerce Microservices on Minikube with Kong & AWS ALB

This repository contains the infrastructure and Kubernetes manifests to deploy a memory-optimized Spring Boot backend and FastAPI frontend on an AWS EC2 instance running Minikube. Traffic is secured and routed using AWS ACM, an Application Load Balancer (ALB), and the Kong Ingress Controller.

## Architecture Overview
*   **Cloud Provider:** AWS (EC2 `t3a.large`, ALB, ACM)
*   **Cluster:** Minikube (Docker driver)
*   **Ingress Controller:** Kong Gateway (DB-less)
*   **Logging:** Fluent Bit & Grafana Loki
*   **Applications:** FastAPI (Frontend) & Spring Boot (Backend) isolated in separate namespaces.
*   **Networking:** TLS offloading at the AWS ALB, forwarding plain HTTP to Kong on Port 80, which routes traffic to internal pods.

## Helm Installatiom

   ```bash
   # Add the Kong Helm repository
   helm repo add kong https://charts.konghq.com
   helm repo update

   # Install Kong in a dedicated namespace
   helm install kong kong/ingress -n kong --create-namespace
   ```

## Deployment Steps

1. **Launch EC2 Instance:** Launch an Ubuntu 24.04 instance and paste the contents of `scripts/01-ec2-user-data.sh` into the Advanced Details > User Data field.
2. **Install Tools:** SSH into the instance (`su - ubuntu`) and run `scripts/02-setup-cluster-tools.sh` to install Kong and the logging stack.
3. **Generate TLS:** Run `scripts/03-generate-tls-secrets.sh` to create the namespaces and self-signed certificates.
4. **Deploy Apps:**
   ```bash
   kubectl apply -f kubernetes/backend.yaml
   kubectl apply -f kubernetes/frontend.yaml
   ```
5. **Bridge the Network:** Run the following command in the background to forward EC2 host traffic to Kong:
   ```bash
   sudo kubectl --kubeconfig=/home/ubuntu/.kube/config port-forward --address 0.0.0.0 svc/kong-gateway-proxy -n kong 80:80 &
   ```
6. **AWS ALB Configuration:**
   - Import the `.crt` and `.key` files generated in Step 3 into AWS Certificate Manager (ACM).
   - Create an HTTP Target Group on Port 80 with success codes 200-404.
   - Create an Application Load Balancer with an HTTPS listener (Port 443) using the ACM certificates, forwarding to the HTTP Target Group (TLS Offloading).
7. **Local Testing:** Map the ALB's IP addresses to `www.my-ecommerce.local` and `api.my-ecommerce.local` in your local Windows hosts file.

> **Note:** The TLS secret attachment was removed from the Kubernetes Ingress manifests, because in the final working design, the AWS ALB handles the TLS offloading before sending plain HTTP to Kong.
