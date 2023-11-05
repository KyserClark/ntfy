#!/bin/bash

# Define where to install ntfy.sh
INSTALL_DIR="/usr/local/bin"

if [[ ! -f "ntfy.sh" ]]; then
    echo "Error: ntfy.sh not found! Please ensure you are in the correct directory."
    exit 1
fi

echo "Setting permissions for ntfy.sh..."
chmod +x ntfy.sh

echo "Installing ntfy.sh to $INSTALL_DIR..."
sudo mv ntfy.sh $INSTALL_DIR/ntfy

echo "ntfy script installed successfully! You can now use it with the 'ntfy' command."
