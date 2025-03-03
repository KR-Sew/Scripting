#!/bin/bash
# Set your subscription if you haven't already
subscriptionID=00000000-0000-0000-0000-00000000
az account set --subscription $subscriptionID

# Get the name of all resource groups that start with 'msdocs'
az group list --query "[?starts_with(name, 'msdocs') == \`true\`].name" -o table

# Delete resource groups without a confirmation prompt (--yes)
# Do not wait for the operation to finish (--no-wait)
for rgList in $(az group list --query "[?starts_with(name, 'msdocs') == \`true\`].name" -o tsv); 
do
    echo "deleting resource group $rgList"
    az group delete --name $rgList --yes --no-wait
done

# get the status of all resource groups in the subscription
az group list --output table