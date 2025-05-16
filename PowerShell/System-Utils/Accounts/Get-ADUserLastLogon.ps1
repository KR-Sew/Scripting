Param (
    [Parameter(Mandatory=$True)]
    [int]$DaysAmount, # Amount of days
    [Parameter(Mandatory=$True)]
    [string]$OutputFilePath, # Path to an output file
    [Parameter(Mandatory=$True)]
    [string]$OutputFileName  # Name of output file
    )

# Define the date threshold for user logon
$LastLogonDate = (Get-Date).AddDays($DaysAmount)

# Retrieve Active Directory users who have not logged on in the last 180 days
# Filter for enabled users only
$inactiveUsers = Get-ADUser -Properties LastLogonTimeStamp -Filter {
    LastLogonTimeStamp -lt $LastLogonDate -and Enabled -eq $True
}
# Add path for output file
$ResultFile = Join-Path $OutputFilePath $OutputFileName
# Sort the results by LastLogonTimeStamp and format the output
$inactiveUsers | 
    Sort-Object LastLogonTimeStamp | 
    Format-Table Name, SamAccountName, @{Name='LastLogonTimestamp'; Expression={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}} -AutoSize | 
    Out-File -FilePath $ResultFile

# Output completion message
Write-Host "Report generated: '$ResultFile'"
