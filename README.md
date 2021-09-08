# UniversalPrint

This remediation script uses the Universal Print Native Client service principal (Enterprise App) to get access to the Universal Print API using the signed in user to authenticate with. Once authenticated, it discovers all printers that have been shared to the user and adds them to printers.csv. The UPPrinterInstaller.exe supplied in the [Universal Print printer provisioning tool](https://aka.ms/UPIntuneTool_DL). You can use the .intunewin file as is, which installs a service that triggers UPPrinterInstaller.exe on user logon, or unpack it and deploy only the UPPrinterInstaller.exe which is ran at the end of the script. It also creates a transcript and drops it in %AppData%\Roaming\UniversalPrintPrinterProvisioning. 

The remediation script only needs to have your tenant ID added on line 26 but since it's using the UP Native Client, an app registration is not needed. 

The detection rule checks if printers.csv has been modified in the past 24 hours and if it hasn't been, it will run the remediation script. You can modify this to suit your needs pretty easily. 
