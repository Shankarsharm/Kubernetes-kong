#!/bin/bash
# Create the isolated namespaces
kubectl create namespace ecommerce-back
kubectl create namespace ecommerce-front

# 1. Generate and apply the Frontend Certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout frontend.key -out frontend.crt -subj "/CN=www.my-ecommerce.local"

kubectl create secret tls frontend-tls \
  --key frontend.key --cert frontend.crt -n ecommerce-front

# 2. Generate and apply the Backend Certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout backend.key -out backend.crt -subj "/CN=api.my-ecommerce.local"

kubectl create secret tls backend-tls \
  --key backend.key --cert backend.crt -n ecommerce-back

echo "Namespaces and TLS secrets created successfully!"
