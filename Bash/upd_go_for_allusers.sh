#!/bin/bash

set -e

export PATH=$PATH:/usr/local/go/bin  # Ensure this is always in PATH for the script

echo "Updating Golang..."

# Function to update Golang
update_golang() {
    echo "Checking latest Golang version..."
    LATEST_GO_VERSION=$(curl -s https://go.dev/dl/ | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | sed 's/go//')

    INSTALLED_GO_VERSION=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')

    if [ "$LATEST_GO_VERSION" == "$INSTALLED_GO_VERSION" ]; then
        echo "Golang is already up to date ($INSTALLED_GO_VERSION)."
    else
        echo "Updating Golang from $INSTALLED_GO_VERSION to $LATEST_GO_VERSION..."

        # Remove old Go installation if exists
        sudo rm -rf /usr/local/go

        # Download and install the latest Go version
        wget "https://go.dev/dl/go${LATEST_GO_VERSION}.linux-amd64.tar.gz"
        sudo tar -C /usr/local -xzf "go${LATEST_GO_VERSION}.linux-amd64.tar.gz"
        rm "go${LATEST_GO_VERSION}.linux-amd64.tar.gz"

        # Add Go to global PATH if not already
        if ! grep -q '/usr/local/go/bin' /etc/profile; then
            echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
        fi

        export PATH=$PATH:/usr/local/go/bin  # Needed for current script

        echo "Golang updated to $(go version)."
    fi
}

update_golang

echo "All updates completed!"
