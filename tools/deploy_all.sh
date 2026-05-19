#!/bin/bash

# Ensure the namespaces exist first (idempotent command)
echo "Creating namespaces kubectl-schulung1 to kubectl-schulung6..."
for i in {1..6}; do
  kubectl create namespace "kubectl-schulung$i" --dry-run=client -o yaml | kubectl apply -f -
done

echo ""
echo "Deploying kubectl pod to each namespace..."

# Loop from 1 to 6
for i in {1..6}; do
  NAMESPACE="kubectl-schulung$i"
  HOST_PATH_DIR="/schulung$i"

  echo "--- Deploying to namespace '$NAMESPACE' with hostPath '$HOST_PATH_DIR' ---"

  # Use sed to replace placeholders and pipe to kubectl apply
  sed -e "s|__NAMESPACE__|${NAMESPACE}|g" \
      -e "s|__HOST_PATH_DIR__|${HOST_PATH_DIR}|g" \
      kubectl-deployment.template.yaml | kubectl apply -f -

  echo ""
done

echo "All deployments completed."
