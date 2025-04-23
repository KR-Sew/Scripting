#!/bin/bash

# Description:
# This script adds execute permission to all regular files in the specified directory.

usage() {
    echo "Usage: $0 /path/to/directory"
    exit 1
}

# Ensure directory argument is provided
if [ -z "$1" ]; then
    usage
fi

dir="$1"

# Check if directory exists and is accessible
if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' does not exist or is not accessible."
    exit 1
fi

# Change permissions using find (non-recursively)
find "$dir" -maxdepth 1 -type f -exec chmod +x {} \;

echo "Execute permissions added to all regular files in '$dir'."
