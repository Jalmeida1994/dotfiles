#!/bin/bash

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

create_kind_cluster() {
    local cluster_name=${1:-"local-cluster"}
    kind create cluster --config "$DOTFILES_DIR/.config/kind/kind-cluster.yaml" --name "$cluster_name"

    # Install ingress-nginx
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

    echo "Waiting for ingress-nginx to be ready..."
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s
}

delete_kind_cluster() {
    local cluster_name=${1:-"local-cluster"}
    kind delete cluster --name "$cluster_name"
}

# Usage
case "$1" in
    create)
        create_kind_cluster "$2"
        ;;
    delete)
        delete_kind_cluster "$2"
        ;;
    *)
        echo "Usage: $0 {create|delete} [cluster_name]"
        exit 1
        ;;
esac
