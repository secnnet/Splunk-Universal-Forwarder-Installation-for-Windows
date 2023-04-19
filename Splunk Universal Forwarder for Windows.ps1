<#
.Synopsis
This is the script that will install Splunk forwarder service on clients.
.Example
Install-Splunk.ps1
.Example
Install-Splunk.ps1 -Force  
.Parameter Force
Use this switch if you want to force a re-install or update versions.
#>

# Define the script parameter that determines whether to force a re-install or update versions.
Param(
    [switch]$Force
)

# Set variables for Splunk folder, version, and file name.
$SplunkFolder = "C:\Program Files\"
$SplunkVersion = "8.2.6-a6fe1ee8894b"
$SplunkFile = Get-ChildItem -Path $SplunkFolder -Filter "splunkforwarder-$SplunkVersion*"

# Set variables for input and output files, domain, and their respective paths.
$InputFile = "C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf"
$Domain = (Get-WmiObject win32_computersystem).domain
$OutputFileSource = "PATH_TO_OUTPUTS.CONF_FILE"
$OutputFile = "C:\Program Files\SplunkUniversalForwarder\etc\system\local\outputs.conf"
$InputFileSource = "PATH_TO_INPUTS.CONF_FILE"

# Check if Splunk forwarder service is already installed, and if so, exit the script if the -Force parameter is not used.
if (Get-Service splunkforwarder -ErrorAction SilentlyContinue) {
    "Splunk forwarder already installed."
    if (!$Force) {
        "-Force argument not used, exiting."
        Start-Sleep 5
        exit 1
    }
}

# If the script reaches this point, it will attempt to install Splunk forwarder.
""
"Going to install Splunk forwarder."
Start-Sleep 1

# Stop the Splunk forwarder service if it is running.
if ((Get-Service splunkforwarder -ErrorAction SilentlyContinue).Status -eq "Running") {
    Stop-Service Splunkforwarder -Verbose -ErrorAction SilentlyContinue
}

# Install the Splunk forwarder using the appropriate MSI file and parameters.
msiexec /i $SplunkFile.FullName /passive AGREETOLICENSE=YES RECEIVING_INDEXER="indexer_fqdn_here" LAUNCHSPLUNK=0 MONITOR_PATH="C:\log" WINEVENTLOG_APP_ENABLE=1 WINEVENTLOG_SEC_ENABLE=1 WINEVENTLOG_SYS_ENABLE=1 WINEVENTLOG_FWD_ENABLE=1 WINEVENTLOG_SET_ENABLE=1 | Out-Null

# Set the Splunk command variable and change the current directory to the Splunk directory.
$SplunkCmd = Get-ChildItem -Path 'C:\Program Files' -Recurse -Filter splunk.exe
cd $SplunkCmd.DirectoryName

# Add a monitor for the specified log file, set the server and default hostname, and restart the Splunk forwarder service.
if (Test-Path C:\log) {
    .\splunk.exe add monitor C:\log -auth admin:changeme
}
.\splunk.exe set servername "$env:computername.$domain" -auth admin:changeme
.\splunk.exe set default-hostname "$env:computername.$domain" -auth admin:changeme

# Modify the inputs.conf file and copy the outputs.conf file.
# Then start the Splunk forwarder service and display a message that the installation is complete.
"Modifying inputs.conf."
Get-Content $InputFileSource | Out-File $
