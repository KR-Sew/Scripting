#!/bin/bash
az ssh vm --private-key-file \path\to\private\key --resource-group $rgName --name $vmName --local-user $vmAdminUserName