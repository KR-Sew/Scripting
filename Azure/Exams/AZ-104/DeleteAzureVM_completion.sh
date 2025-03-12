#!/bin/bash

# Function to get VM names from Azure
_get_azure_vms() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Fetch VM names from Azure CLI
    local vms=$(az vm list --query "[].name" -o tsv)
    
    # Generate completions based on user input
    COMPREPLY=( $(compgen -W "$vms" -- "$cur") )
}

# Function to get resource group names from Azure
_get_azure_resource_groups() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Fetch resource group names from Azure CLI
    local groups=$(az group list --query "[].name" -o tsv)
    
    # Generate completions based on user input
    COMPREPLY=( $(compgen -W "$groups" -- "$cur") )
}

# Main completion function
_complete_delete_azure_vm() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # First argument is VM name
    if [ $COMP_CWORD -eq 1 ]; then
        _get_azure_vms
    fi

    # Second argument is resource group
    if [ $COMP_CWORD -eq 2 ]; then
        _get_azure_resource_groups
    fi
}

# Register completion function for the script
complete -F _complete_delete_azure_vm ./delete-azure-vm.sh
