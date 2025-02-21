
$UserName = Read-Host -Prompt "Enter a local user name"
$NewPassword = Read-Host -Prompt "Enter Password. Remeber the password must be 8 symbols at least. Just in put it" -AsSecureString
# Set the new password
try {
    Set-LocalUser -Name $UserName -Password $NewPassword
    Write-Host "Password for user '$UserName' has been successfully set." -ForegroundColor Green
}
catch {
    # Output error message
    Write-Host "Failed to set password for user '$UserName'. Error: $_" -ForegroundColor Red
}
