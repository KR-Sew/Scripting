#!/bin/bash

set -e

echo "Updating Rclone..."

# Function to update Rclone
update_rclone() {
    echo "Checking latest Rclone version..."
    LATEST_RCLONE_VERSION=$(curl -s https://api.github.com/repos/rclone/rclone/releases/latest | grep '"tag_name":' | cut -d '"' -f 4 | sed 's/v//')

    INSTALLED_RCLONE_VERSION=$(rclone version | head -n 1 | awk '{print $2}' || echo "0")

    if [ "$LATEST_RCLONE_VERSION" == "$INSTALLED_RCLONE_VERSION" ]; then
        echo "Rclone is already up to date ($INSTALLED_RCLONE_VERSION)."
    else
        echo "Updating Rclone from $INSTALLED_RCLONE_VERSION to $LATEST_RCLONE_VERSION..."

        # Download and install the latest Rclone version
        curl -O "https://downloads.rclone.org/v${LATEST_RCLONE_VERSION}/rclone-v${LATEST_RCLONE_VERSION}-linux-amd64.deb"
        sudo dpkg -i "rclone-v${LATEST_RCLONE_VERSION}-linux-amd64.deb"
        rm "rclone-v${LATEST_RCLONE_VERSION}-linux-amd64.deb"

        echo "Rclone updated to $(rclone version | head -n 1)."
    fi
}

update_rclone

echo "All updates completed!"
