#!/bin/bash

set -e

echo "Updating Git and GitHub CLI..."

# Function to update Git
update_git() {
    echo "Checking latest Git version..."
    LATEST_GIT_VERSION=$(curl -s https://mirrors.edge.kernel.org/pub/software/scm/git/ | grep -oP 'git-\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)

    INSTALLED_GIT_VERSION=$(git --version | awk '{print $3}' || echo "0")

    if [ "$LATEST_GIT_VERSION" == "$INSTALLED_GIT_VERSION" ]; then
        echo "Git is already up to date ($INSTALLED_GIT_VERSION)."
    else
        echo "Updating Git from $INSTALLED_GIT_VERSION to $LATEST_GIT_VERSION..."
        sudo apt remove --yes git || true
        sudo apt install --yes make libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext
        wget "https://mirrors.edge.kernel.org/pub/software/scm/git/git-${LATEST_GIT_VERSION}.tar.gz"
        tar -xf "git-${LATEST_GIT_VERSION}.tar.gz"
        cd "git-${LATEST_GIT_VERSION}"
        make prefix=/usr/local all
        sudo make prefix=/usr/local install
        cd ..
        rm -rf "git-${LATEST_GIT_VERSION}" "git-${LATEST_GIT_VERSION}.tar.gz"
        echo "Git updated to $(git --version)."

        # Reinstall Git via APT to satisfy dependencies
        sudo apt install --yes git
    fi
}

# Function to update GitHub CLI
update_gh() {
    echo "Checking latest GitHub CLI version..."
    LATEST_GH_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep '"tag_name":' | cut -d '"' -f 4 | cut -c2-)

    INSTALLED_GH_VERSION=$(gh --version | head -n 1 | awk '{print $3}' || echo "0")

    if [ "$LATEST_GH_VERSION" == "$INSTALLED_GH_VERSION" ]; then
        echo "GitHub CLI is already up to date ($INSTALLED_GH_VERSION)."
    else
        echo "Updating GitHub CLI from $INSTALLED_GH_VERSION to $LATEST_GH_VERSION..."
        wget "https://github.com/cli/cli/releases/download/v${LATEST_GH_VERSION}/gh_${LATEST_GH_VERSION}_linux_amd64.deb"
        sudo dpkg -i "gh_${LATEST_GH_VERSION}_linux_amd64.deb"
        
        # Fix dependencies if needed
        sudo apt install -f --yes
        
        rm "gh_${LATEST_GH_VERSION}_linux_amd64.deb"
        echo "GitHub CLI updated to $(gh --version | head -n 1)."
    fi
}

update_git
update_gh

echo "All updates completed!"
