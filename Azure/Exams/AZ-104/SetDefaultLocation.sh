# Set the default location by region 
# available: Westus2,southcentralus,centralus,#eastus,westeurope,southeastasia,japaneast,brazilsouth,australiasoutheast,centralindia

az configure --defaults location=westeurope

# Set the name of default resource group

az configure --defaults group="[sandbox Resource Group]"
