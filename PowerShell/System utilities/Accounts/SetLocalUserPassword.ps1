# Prompt for the local user name
$UserName = Read-Host -Prompt "Enter a local user name"

# Prompt for the new password as a SecureString
$NewPassword = Read-Host -Prompt "Enter Password. Remember the password must be at least 8 characters long." -AsSecureString

# Set the new password
try {
    Set-LocalUser -Name $UserName -Password $NewPassword
    Write-Host "Password for user '$UserName' has been successfully set." -ForegroundColor Green
}
catch {
    # Output error message
    Write-Host "Failed to set password for user '$UserName'. Error: $_" -ForegroundColor Red
}
