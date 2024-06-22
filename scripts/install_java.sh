#!/bin/bash

set -euo pipefail

install_java() {
    local version=$1
    local arch=$(uname -m)
    local url

    # Check if the specified version is already installed
    if /usr/libexec/java_home -v $version &>/dev/null; then
        echo "Java $version is already installed."
        return
    fi

    if [[ "$arch" == "arm64" ]]; then
        url="https://corretto.aws/downloads/latest/amazon-corretto-${version}-aarch64-macos-jdk.pkg"
    else
        url="https://corretto.aws/downloads/latest/amazon-corretto-${version}-x64-macos-jdk.pkg"
    fi

    echo "Downloading Amazon Corretto ${version} for ${arch}..."
    curl -L -o "corretto-${version}.pkg" "$url"

    echo "Installing Amazon Corretto ${version}..."
    sudo installer -pkg "corretto-${version}.pkg" -target /

    echo "Cleaning up..."
    rm "corretto-${version}.pkg"

    echo "Amazon Corretto ${version} installed successfully."
}

# Install Java 17
install_java 17

# Install Java 21
install_java 21

# Update jenv
echo "Updating jenv with new Java versions..."
jenv add $(/usr/libexec/java_home -v 17)
jenv add $(/usr/libexec/java_home -v 21)

echo "Java installation complete. You can now use jenv to switch between versions."
