#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
DEFAULT_CLUSTER_NAME="default-cluster"
KIND_CONFIG="$DOTFILES_DIR/.config/kind/kind-cluster.yaml"

# Function to check if a Kind cluster exists
cluster_exists() {
    kind get clusters 2>/dev/null | grep -q "^$1$"
}

# Function to create a Kind cluster
create_kind_cluster() {
    local cluster_name=${1:-"$DEFAULT_CLUSTER_NAME"}
    if cluster_exists "$cluster_name"; then
        echo "Cluster '$cluster_name' already exists."
    else
        echo "Creating Kind cluster: $cluster_name"
        kind create cluster --config "$KIND_CONFIG" --name "$cluster_name"

        echo "Installing ingress-nginx..."
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

        echo "Waiting for ingress-nginx to be ready..."
        kubectl wait --namespace ingress-nginx \
          --for=condition=ready pod \
          --selector=app.kubernetes.io/component=controller \
          --timeout=90s
    fi
}

# Function to delete a Kind cluster
delete_kind_cluster() {
    local cluster_name=${1:-"$DEFAULT_CLUSTER_NAME"}
    if cluster_exists "$cluster_name"; then
        echo "Deleting Kind cluster: $cluster_name"
        kind delete cluster --name "$cluster_name"
    else
        echo "Cluster '$cluster_name' does not exist."
    fi
}

# Main execution
if ! command -v kind &> /dev/null; then
    echo "Kind is not installed. Please install it first."
    exit 1
fi

# Check if a default cluster exists, if not, create one
if ! cluster_exists "$DEFAULT_CLUSTER_NAME"; then
    create_kind_cluster "$DEFAULT_CLUSTER_NAME"
else
    echo "Default Kind cluster '$DEFAULT_CLUSTER_NAME' already exists."
fi

# Provide options for additional actions
echo "Kind cluster setup complete."
echo "You can use the following commands for cluster management:"
echo "  create_kind_cluster [cluster_name]"
echo "  delete_kind_cluster [cluster_name]"

# Export functions for use in the shell
export -f create_kind_cluster
export -f delete_kind_cluster
