#!/bin/bash

set -e

echo "Updating Gawk..."

# Ensure required tools are installed
if ! command -v wget &> /dev/null; then
    echo "wget not found, installing..."
    sudo apt update && sudo apt install -y wget
fi
if ! command -v curl &> /dev/null; then
    echo "curl not found, installing..."
    sudo apt update && sudo apt install -y curl
fi

# Function to update Gawk
update_gawk() {
    echo "Checking latest Gawk version..."

    # Fetch available versions and extract the latest one
    LATEST_GAWK_VERSION=$(curl -s https://ftp.gnu.org/gnu/gawk/ | grep -oP 'gawk-\K[0-9]+\.[0-9]+(\.[0-9]+)?(?=\.tar\.gz)' | sort -V | tail -n 1)

    if [ -z "$LATEST_GAWK_VERSION" ]; then
        echo "Error: Failed to fetch the latest Gawk version. Exiting."
        exit 1
    fi

    INSTALLED_GAWK_VERSION=$(gawk --version | head -n 1 | awk '{print $3}' | sed 's/,$//')

    if [ "$LATEST_GAWK_VERSION" == "$INSTALLED_GAWK_VERSION" ]; then
        echo "Gawk is already up to date ($INSTALLED_GAWK_VERSION)."
        exit 0
    else
        echo "Updating Gawk from $INSTALLED_GAWK_VERSION to $LATEST_GAWK_VERSION..."

        # Install dependencies
        sudo apt update
        sudo apt install --yes build-essential libreadline-dev

        # Download and compile the latest Gawk version
        GAWK_TAR="gawk-${LATEST_GAWK_VERSION}.tar.gz"
        GAWK_URL="https://ftp.gnu.org/gnu/gawk/$GAWK_TAR"

        echo "Downloading $GAWK_URL..."
        wget "$GAWK_URL"

        tar -xf "$GAWK_TAR"
        cd "gawk-${LATEST_GAWK_VERSION}"
        ./configure --prefix=/usr/local
        make -j$(nproc)
        sudo make install
        cd ..
        rm -rf "gawk-${LATEST_GAWK_VERSION}" "$GAWK_TAR"

        echo "Gawk updated to $(gawk --version | head -n 1)."
    fi
}

update_gawk

echo "All updates completed!"
