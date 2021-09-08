$printerCsv = get-item $env:APPDATA\UniversalPrintPrinterProvisioning\Configuration\printers.csv
$ts = New-TimeSpan -Days 1

if (($printerCsv.LastWriteTime + $ts) -gt (get-date)) {
    Write-Host "Success"
    exit 0
} else {
    Write-Host $printerCsv.Name "needs updated."
    exit 1
}
