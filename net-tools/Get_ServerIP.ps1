# Name: Get_ServerIP.ps1
# Purpose: Get the IP address for servers listed in a json file.
# Usage: Get_ServerIP.ps1 -ConfigFile [serverList] -LogFile [logFile]
# Comments:
# - ConfigFile: Optional, defaults to serverList.json, but you may specify a different config file by -ConfigFile parameter.
#   Please update the info in the config file before running the script.
# - LogFile: Optional, defaults to the Logs folder. The Logs folder is created if it is missing.
# Content of serverList.json:
<#
{   
    "servers": [
        {"name": "server_1"},
        {"name": "server_2"},
        {"name": "server_3"}
    ]
}
#>
 
# Set the policy to enable PS Scripts:
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

param (
    $ConfigFile = (Get-Location).Path + "\serverList.json",
    $LogFile = "defaultLog.log"
)

$wkPath=(Get-Location).Path
if ($LogFile -eq "defaultLog.log") {
    $logPath="$wkPath\Logs"
    if (-not(Test-Path -Path $logPath)) {$null = New-Item -ItemType Directory -Path $logPath -Force}
    $LogFile="$logPath\Get_ServerIP_" + (Get-Date -Format "yyyy-MM-dd-HHmm") + ".log"
}Start-Transcript -Path $LogFile -Append
Write-Host "**********************`n"
Write-Host "`n"

$QueryConfig=Get-Content -Path $ConfigFile | ConvertFrom-json
$servers=$QueryConfig.servers

for ($i=0; $i -lt $servers.Count; $i++) {
        Resolve-DnsName $servers[$i].name | Format-Table Name, IPAddress -HideTableHeaders 
}

Stop-Transcript
