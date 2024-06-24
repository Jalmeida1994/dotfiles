#!/bin/bash
set -euo pipefail

echo "Setting up Docker Buildx..."

# Create necessary directory
mkdir -p ~/.docker/cli-plugins

# Create symlink
ln -sfn "$(brew --prefix)/opt/docker-buildx/bin/docker-buildx" ~/.docker/cli-plugins/docker-buildx

# Install buildx
docker buildx install

echo "Docker Buildx setup complete."
