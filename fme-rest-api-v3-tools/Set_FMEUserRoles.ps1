<# Name: Set_FMEUserRoles.ps1
Purpose: Read FME User Roles from a Json file, and write the items back to FME.
Usage:
- Short form: Get_FMEUserRoles.ps1 http(s)://fmeserver abcd23er...32fg E:\apps_data\FME\FME_UserRoles.json
- Long form: Get_FMEUserRoles -URL http(s)://fmeserver -token abcd23er...32fg -userRoles E:\apps_data\FME\FME_UserRoles.json -dataDir [Directory for Output] -LogFile Set_UserRoles.log
Comments:
- FME REST API V3
- dataDir defaults to the current folder.
#>

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string][ValidateNotNullOrEmpty()]$URL,
    [Parameter(Mandatory=$true, Position=1)]
    [string][ValidateNotNullOrEmpty()]$token,
    [Parameter(Mandatory=$true, Position=2)]
    [string][ValidateNotNullOrEmpty()]$userRoles,
    $dataDir = (Get-Location).Path + "\data",
    $LogFile = "Set_FMEUserRoles.log"
)

Import-Module ./FME_RestAPI_Common.psm1

# Create Data Folder
if (-not (Test-Path -Path $dataDir)) {New-Item -ItemType "directory" -Path $dataDir}
if (-not ($dataDir -like "*\")) {$dataDir = $dataDir + "\"}
$LogFile = $dataDir + $LogFile
Start-Transcript -Path $LogFile -Append
# Backup current user roles
$ts = Get-Timestamp
$outFile = $dataDir + "UserRoles_Backup_" + $ts + ".json"
Get-UserRoles -URL $URL -token $token -outFile $outFile
Write-Host "Backup User Roles File: $outFile"
# Set user roles based on input file $userRoles
Set-UserRoles -URL $URL -token $token -userRoles $userRoles
$ts = Get-Timestamp
$outFile = $dataDir + "UserRoles_Updated_" + $ts + ".json"
# Export updated user roles
Get-UserRoles -URL $URL -token $token -outFile $outFile
Write-Host "Updated User Roles File: $outFile"

Stop-Transcript
