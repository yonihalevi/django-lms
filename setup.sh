#!/bin/bash

# Step 1: Switch Docker to use Minikube's Docker daemon
echo "Switching Docker CLI to Minikube..."
eval $(minikube docker-env)

# Optional: Build Docker image in Minikube if needed
# echo "Building Django LMS Docker image..."
# docker build -t django-lms:local .

# Step 2: Apply K8s resources
echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/db-secret.yaml
# kubectl apply -f k8s/django-secret.yaml
# kubectl apply -f k8s/django-config.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/adminer-deployment.yaml
# kubectl apply -f k8s/django-deployment.yaml

# Step 3: Wait for resources to be ready
echo "Waiting for PostgreSQL pod to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s || exit 1

echo "Waiting for Redis pod to be ready..."
kubectl wait --for=condition=ready pod -l app=redis --timeout=120s || exit 1

echo "Waiting for Adminer pod to be ready..."
kubectl wait --for=condition=ready pod -l app=adminer --timeout=120s || exit 1

# Step 4: Port-forward services in background
echo "Port forwarding PostgreSQL (5432), Redis (6379), and Adminer (8080)..."
kubectl port-forward svc/postgres 5432:5432 &
kubectl port-forward svc/redis 6379:6379 &
kubectl port-forward svc/adminer 8080:8080 &

echo "All services are running and forwarded!"
echo "You can access Adminer at http://localhost:8080"
echo "Press Ctrl+C to stop port forwarding."

# Optional: Keep the script running
wait
