#!/bin/bash

# Define where to install ntfy.sh
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/ntfy"

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update package list
echo "Updating package list..."
apt update

# Install Docker, Python3, and pip
echo "Installing dependencies: Docker, Python3, and pip..."
apt install -y docker.io python3 python3-pip

# Install Python packages with pip3
echo "Installing Python packages: pyyaml and ruamel.yaml..."
pip3 install pyyaml ruamel.yaml

# Install curl
apt install curl

# Check if ntfy.sh exists in the current directory
if [[ ! -f "ntfy.sh" ]]; then
    echo "Error: ntfy.sh not found! Please ensure it's in the current directory or provide the path."
    exit 1
fi

# Set execute permissions for ntfy.sh
chmod +x ntfy.sh

# Move ntfy.sh to the installation directory
mv ntfy.sh "$INSTALL_DIR/ntfy" || {
    echo "Failed to install ntfy.sh to $INSTALL_DIR."
    exit 1
}

# Check if server.yml exists in the current directory
if [[ ! -f "server.yml" ]]; then
    echo "Warning: server.yml not found! If you wish to use a custom configuration, please place it in $CONFIG_DIR/server.yml manually."
else
    # Ensure the configuration directory exists
    mkdir -p "$CONFIG_DIR"

    # Move server.yml to the configuration directory
    mv server.yml "$CONFIG_DIR/server.yml" || {
        echo "Failed to move server.yml to $CONFIG_DIR."
        exit 1
    }
fi

echo "ntfy script installed successfully! You can now use it with the 'ntfy' command."
