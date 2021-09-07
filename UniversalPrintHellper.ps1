Start-Transcript -Path $env:APPDATA\UniversalPrintPrinterProvisioning\UPHellper.txt -IncludeInvocationHeader

if (Get-Module -ListAvailable -Name PowerShellGet) {
    Write-Host "PowerShellGet is installed."
}
else {
    Write-Host "Installing PowerShellGet"
    Install-Module -Name PowerShellGet -Force
}

if (Get-Module -ListAvailable -Name msal.ps) {
    Write-Host "MSAL.PS is installed."
    Write-Host "Checking for newer version."
    if ((Find-Module MSAL.PS).Version -gt (Get-Module MSAL.PS).Version ) {
        Write-Host "Newer version found. Updating."
        Update-Module MSAL.PS -Force -AcceptLicense
    } else {
        Write-Host "MSAL.PS is on the latest version."
    }
}
else {
    Write-Host "Installing MSAL.PS"
    Install-Module -Name MSAL.PS -AcceptLicense -Force
}

$tenantId = "***REMOVED***"
$clientId = "dae89220-69ba-4957-a77a-47b78695e883"
$upn = whoami /upn
$redirectUri = "https://MicrosoftPrintClient"
$Scopes = "https://print.print.microsoft.com/printerproperties.read https://print.print.microsoft.com/printers.read https://print.print.microsoft.com/printjob.readwrite"

try {
    Write-Host "Getting Auth Token."
    
    try {
        $Token = Get-MsalToken -ClientId $clientId -Scopes $Scopes -TenantId $tenantId -RedirectUri $redirectUri -LoginHint $upn -IntegratedWindowsAuth
        Write-Host "Authentication granted for" $token.Account.Username"."
    } catch {
        $errMsg = $_.Exception.Message
        Write-Host "Integrated Windows Authentication is not available."
        Write-Host $errMsg
        Write-Host "Falling back on Interactive Authentication."
        $Token = Get-MsalToken -ClientId $clientId -Scopes $Scopes -TenantId $tenantId -RedirectUri $redirectUri -LoginHint $upn -Interactive
        Write-Host "Authentication granted for" $token.Account.Username"."
    }
    
    Write-Host "Getting all printers assigned to user."
    $apiUrl = 'https://discovery.print.microsoft.com/api/mod1.0/devices'
    $rest = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Token.AccessToken)" } -Uri $apiUrl -Method Get
    Write-Host $rest.devices.count" printers found."
    $printers = @()

    foreach ($x in $rest.devices) {
        $printers += @(
            [PSCustomObject]@{
                SharedId   = $x.uuid
                SharedName = $x.device_names.name
                IsDefault  = $null
            }
        )
        Write-Host "Adding "$x.device_names.name" to printers.csv"
    }

    Write-Host "Saving printers.csv to $env:APPDATA\UniversalPrintPrinterProvisioning\Configuration"
    New-Item -ItemType Directory $env:APPDATA\UniversalPrintPrinterProvisioning\Configuration -ErrorAction Ignore
    $printers | Export-Csv -Path $env:APPDATA\UniversalPrintPrinterProvisioning\Configuration\printers.csv -Force -NoTypeInformation
    $content = Get-Content -Path $env:APPDATA\UniversalPrintPrinterProvisioning\Configuration\printers.csv | % { $_ -replace '"', '' }
    Set-Content $env:APPDATA\UniversalPrintPrinterProvisioning\Configuration\printers.csv $content
    Write-Host "Launching UPPrinterInstaller.exe"
    & 'C:\Program Files (x86)\UniversalPrintPrinterProvisioning\Exe\UPPrinterInstaller.exe'
    Write-Host "Universal Print Printers are now installed."
}
catch {
    $errMsg = $_.Exception.Message
    Write-Host $errMsg
    exit 1
}

Stop-Transcript 