# Set the default location by region 
# available: Westus2,southcentralus,centralus,#eastus,westeurope,southeastasia,japaneast,brazilsouth,australiasoutheast,centralindia
#To check your default configuration, run: az configure --list-defaults

#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define parameters
region="$1"
resGroup="$2"

# Validate input
if [[ -z "$region" || -z "$resGroup" ]]; then
    echo "Usage: $0 <region> <resource-group>"
    exit 1
fi

# Configure default location by region
az configure --defaults location="$region" --defaults group="$resGroup"

