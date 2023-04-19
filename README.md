"Modifying inputs.conf."
Get-Content $InputFileSource | Out-File $InputFile

"Copying outputs.conf."
Copy-Item $OutputFileSource $OutputFile -Force

"Starting Splunk forwarder service."
Start-Service splunkforwarder -Verbose -ErrorAction SilentlyContinue

"Installation of Splunk forwarder completed."

In summary, this script installs the Splunk forwarder service on clients. It first checks if the Splunk forwarder is already installed, and if it is, the script exits unless the -Force parameter is used. The script then installs the Splunk forwarder using the appropriate MSI file and parameters, sets the server and default hostname, and modifies the inputs.conf and outputs.conf files. Finally, it starts the Splunk forwarder service and displays a message that the installation is complete.
