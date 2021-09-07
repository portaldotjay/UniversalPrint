$printerCsv = get-item $env:APPDATA\UniversalPrintPrinterProvisioning\Configuration\printers.csv
$ts = New-TimeSpan -Days 1

try {
    if (($printerCsv.LastWriteTime + $ts) -gt (get-date)) {
        Write-Host "Success"
        exit 0
    }
}
catch {
    $errMsg = $_.Exception.Message
    Write-Host $errMsg
    exit 1
}