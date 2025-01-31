# Name: Query_Ports.ps1
# Purpose: Query ports for accessibility.
# Usage: Query_Ports.ps1 -ConfigFile [configfile] -LogFile [logFile]
# Comments:
# - ConfigFile: Optional, defaults to serverPortList.json, but you may specify a different config file by -ConfigFile parameter.
#   Please update the info in the config file before running the script.
# - LogFile: Optional, defaults to the Logs folder. The Logs folder is created if it is missing.
# Content of serverPortList.json:
<#
{   
    "defaultPorts": ["1002", "1005", "1100-1113", "1521"],
    "comments": [
        "Ports can be a specific port (eg. 1007) or a range of ports (eg. 1100-1103)",
        "defaultPorts are used if a specific server's ports field is blank []",
        "Specify ports for a specific server to override the default ports."
    ],
    "Servers": [
        {"name": "server_1.domain_1", "ports": ["5438"]},
        {"name": "www.some_site.com", "ports": []},
        {"name": "some_host", "ports": []},
        {"name": "server_2.domain_1", "ports": ["1007", "2200-2203", "5521"]}
    ]
}
#>

# Set the policy to enable PS Scripts:
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

param (
    $ConfigFile = (Get-Location).Path + "\serverPortList.json",
    $LogFile = "defaultLog.log"
)

$wkPath=(Get-Location).Path
if ($LogFile -eq "defaultLog.log") {
    $logPath="$wkPath\Logs"
    if (-not(Test-Path -Path $logPath)) {$null = New-Item -ItemType Directory -Path $logPath -Force}
    $LogFile="$logPath\Query_Ports_" + (Get-Date -Format "yyyy-MM-dd-HHmm") + ".log"
}

Start-Transcript -Path $LogFile -Append
Write-Host "**************************************`n"
Write-Host "`n"

$QueryConfig=Get-Content -Path $ConfigFile | ConvertFrom-json
$defaultPorts=$QueryConfig.defaultPorts
$servers=$QueryConfig.servers

Write-Host "defaultPorts: " $defaultPorts
Write-Host "======================================"
Write-Host

for ($i=0; $i -lt $servers.Count; $i++) {
    $svrPorts=$servers[$i].ports
    Write-Host $servers[$i].name " :: ports: $svrPorts"

    if ($servers[$i].ports -gt 0) {
        $ports = $servers[$i].ports
    } else {
        $ports = $defaultPorts
    }
    Write-Host "Actual ports used for scanning: $ports"
    Write-Host "-------------------------------------------"

    for ($j=0; $j -lt $ports.Count; $j++) {
        # Option 1. Use portqry.exe
        #$cmd=".\portqry.exe"
        #& $cmd -n $servers[$i] -e $ports[$j]
        # Option 2. telnet is not supported in Powershell. telnet syntax: telnet computerName port
        # Option 3. Use Test-NetConnection
        $arPorts = $ports[$j].Split("-")
        #Write-Host "arPorts: " + $arPorts
        for ($k=[int]$arPorts[0]; $k -lt [int]$arPorts[$arPorts.Count - 1]+1; $k++) {
            #Write-Host "Current port: $k"
            Test-NetConnection -ComputerName $servers[$i].name -Port $k
        }
    }
}

Stop-Transcript
