<# Name: Set_FMESchedules.ps1
Purpose: Read FME Schedules from a Json file, and write schedule items back to FME.
Usage:
- Short form: Set_FMESchedules.ps1 http(s)://fmeserver abcd23er...32fg E:\apps_data\FME\FME_Schedule.json
- Long form: Set_FMESchedules -URL http(s)://fmeserver -token abcd23er...32fg -Schedules E:\apps_data\FME\FME_Schedule.json -dataDir [Directory for Output]
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
    [string][ValidateNotNullOrEmpty()]$Schedules,
    $dataDir = (Get-Location).Path + "\data",
    $LogFile = "Set_FMESchedules.log"
)

Import-Module ./FME_RestAPI_Common.psm1

# Create Data Folder
if (-not (Test-Path -Path $dataDir)) {New-Item -ItemType "directory" -Path $dataDir}
if (-not ($dataDir -like "*\")) {$dataDir = $dataDir + "\"}
$LogFile = $dataDir + $LogFile
Start-Transcript -Path $LogFile -Append
$ts = Get-Timestamp
$outFile = $dataDir + "Schedules_Backup_" + $ts + ".json"
# Build REST API URL/URI
$classURL = Get-FMEClassURL $URL "schedules"
$JsonDepth = Get-JsonDepth
Write-Host "Class URL: $classURL, Json Depth: $JsonDepth" 
$tokenStr = Get-TokenString $token
$uri = $classURL + "?limit=-1&offset=-1" + $tokenStr
Write-Host "Request URL: $uri"
# Get FME Schedules
$FMEObject = Invoke-RestMethod -Uri $uri  -Method 'GET' -ContentType 'application/json'
# Backup Current Schdules
$FMEObject | ConvertTo-Json -Depth $JsonDepth | Out-File $outFile
Write-Host "Output Backup Schedules: $outFile"
# Get FME Schedules to Be Updated
$FMEObject = Get-Content -Path $Schedules | ConvertFrom-Json
# Global Update Schedule Parameter Values
# - Update your Json file specified by $Schedules before running the script
foreach ($sch in $FMEObject.items) {
    $classURL = Get-FMEClassURL $URL ("schedules/" + $sch.category + "/" + $sch.name)
    #$uri = "schedules/" + $sch.category + "/" + $sch.name
    $uri = $classURL + "?" + $tokenStr
    $stBody = $sch | ConvertTo-Json -Depth $JsonDepth
    Invoke-RestMethod -Uri $uri  -Method 'PUT' -ContentType 'application/json' -Body $stBody
}

$outFile = $dataDir + "Schedules_Updated_" +  (Get-Date -Format "yyyy-MM-dd-HHmm") + ".json"
$FMEObject | ConvertTo-Json -Depth $JsonDepth | Out-File $outFile
Write-Host "Output Updated Schedules: $outFile" 
Stop-Transcript