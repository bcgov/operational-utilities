<# Name: Get_FMEUserRoles.ps1
Purpose: Download FME User Roles in JSON format through FME API.
Usage:
- Short form: Get_FMEUserRoles.ps1 http(s)://fmeserver abcd23er...32fg
- Long form: Get_FMEUserRoles -URL http(s)://fmeserver -token abcd23er...32fg -dataDir [Directory for Output]
Comments:
- FME REST API V3
- dataDir defaults to the current folder.
#>

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string][ValidateNotNullOrEmpty()]$URL,
    [Parameter(Mandatory=$true, Position=1)]
    [string][ValidateNotNullOrEmpty()]$token,
    $dataDir = (Get-Location).Path + "\data",
    $LogFile = "Get_FMEUserRoles.log"
)

Import-Module ./FME_RestAPI_Common.psm1

# Create Data Folder
if (-not (Test-Path -Path $dataDir)) {New-Item -ItemType "directory" -Path $dataDir}
if (-not ($dataDir -like "*\")) {$dataDir = $dataDir + "\"}
$LogFile = $dataDir + $LogFile
Start-Transcript -Path $LogFile -Append
$ts = Get-Timestamp
$outFile = $dataDir + "UserRoles_" + $ts + ".json"
Get-UserRoles -URL $URL -token $token -outFile $outFile
Write-Host "Output File: $outFile" 
Stop-Transcript
