function Import-WindowsCACertificate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$CAHostname,

        [Parameter()]
        [string]$CertFilePath = "$env:TEMP\ca_cert.cer",

        [Parameter()]
        [ValidateSet("Root", "CA", "My", "AuthRoot", "TrustedPublisher", "Disallowed")]
        [string]$StoreName = "Root"
    )

    # Build the full config string
    $caConfig = "$CAHostname\CA"

    # Download the CA certificate using certutil
    Write-Host "Retrieving CA certificate from $caConfig..."
    $certutilResult = certutil -config $caConfig -ca.cert $CertFilePath 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to retrieve the certificate from $caConfig. Error: $certutilResult"
        return
    }

    # Import the certificate into the selected store
    $certStorePath = "Cert:\LocalMachine\$StoreName"
    Write-Host "Importing certificate to store: $certStorePath"

    try {
        Import-Certificate -FilePath $CertFilePath -CertStoreLocation $certStorePath | Out-Null
        Write-Host "Certificate successfully imported to $certStorePath"
    } catch {
        Write-Error "Failed to import the certificate. $_"
    }
}

# Register argument completer for tab completion if script is dot-sourced
Register-ArgumentCompleter -CommandName Import-WindowsCACertificate -ParameterName StoreName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    'Root', 'CA', 'My', 'AuthRoot', 'TrustedPublisher', 'Disallowed' | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
