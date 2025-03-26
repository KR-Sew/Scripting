function Send-Msg {
    param (
        [string]$ConfigFile,     # JSON file with SMTP settings
        [string]$RecipientsFile, # JSON or TXT file with recipient details
        [string]$BodyFile        # JSON or TXT file with email body
    )

    # Validate input files
    foreach ($File in @($ConfigFile, $RecipientsFile, $BodyFile)) {
        if (-not (Test-Path $File)) {
            Write-Host "Error: File '$File' not found!" -ForegroundColor Red
            exit
        }
    }

    # Read SMTP Config from JSON
    $Config = Get-Content $ConfigFile | ConvertFrom-Json
    $SMTPServer = $Config.smtp_server
    $SMTPPort = $Config.smtp_port
    $Username = $Config.username
    $UseSSL = $Config.use_ssl

    # Retrieve Secure Password
    $Credential = Get-StoredCredential -Target "SMTP_Credentials_$Username"

    if (-not $Credential) {
        Write-Host "No stored credentials found for '$Username'. Please enter your password."
        $SecurePassword = Read-Host "Enter SMTP Password" -AsSecureString
        New-StoredCredential -Target "SMTP_Credentials_$Username" -UserName $Username -SecurePassword $SecurePassword -Persist
        $Credential = Get-StoredCredential -Target "SMTP_Credentials_$Username"
    }

    # Read Recipients File (JSON or TXT)
    if ($RecipientsFile -match "\.json$") {
        $RecipientsData = Get-Content $RecipientsFile | ConvertFrom-Json
        $From = $RecipientsData.from
        $To = $RecipientsData.to -join ","
        $Subject = $RecipientsData.subject
    } else {
        $Lines = Get-Content $RecipientsFile
        $From = ($Lines | Where-Object { $_ -match "^From:" }) -replace "^From:\s*"
        $To = ($Lines | Where-Object { $_ -match "^To:" }) -replace "^To:\s*"
        $Subject = ($Lines | Where-Object { $_ -match "^Subject:" }) -replace "^Subject:\s*"
    }

    # Read Body File (JSON or TXT)
    if ($BodyFile -match "\.json$") {
        $Body = Get-Content $BodyFile | ConvertFrom-Json | Select-Object -ExpandProperty body
    } else {
        $Body = Get-Content $BodyFile -Raw
    }

    # Send Email
    Send-MailMessage -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl:$UseSSL `
        -Credential $Credential -From $From -To $To -Subject $Subject -Body $Body

    Write-Host "Email sent successfully!" -ForegroundColor Green
}

# Helper Functions for Secure Credential Storage
function Get-StoredCredential {
    param ($Target)
    return Get-StoredCredential -Target $Target -ErrorAction SilentlyContinue
}

function New-StoredCredential {
    param ($Target, $UserName, $SecurePassword, $Persist)
    New-StoredCredential -Target $Target -UserName $UserName -SecurePassword $SecurePassword -Persist
}
