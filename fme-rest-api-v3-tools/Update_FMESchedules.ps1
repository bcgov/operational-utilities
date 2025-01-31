<# Name: Update_FMESchedules.ps1
Purpose: Read current FME Schedules, apply global changes and then write back to FME.
Usage:
- Short form: Update_FMESchedules.ps1 http(s)://fmeserver abcd23er...32fg
- Long form: Update_FMESchedules -URL http(s)://fmeserver -token abcd23er...32fg -dataDir [Directory for Output]
Comments:
- API V3
- dataDir defaults to the current folder.
- ! Update the "Global Update Schedule Parameter Values" section before running the script!!!
#>

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string][ValidateNotNullOrEmpty()]$URL,
    [Parameter(Mandatory=$true, Position=1)]
    [string][ValidateNotNullOrEmpty()]$token,
    $dataDir = (Get-Location).Path + "\data",
    $LogFile = "Update_FMESchedules.log"
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
# Global Update Schedule Parameter Values
# - Update itm.name and itm.value in this section to your needs before running the script
foreach ($sch in $FMEObject.items) {
    foreach ($itm in $sch.request.publishedParameters) {
        switch ($itm.name) {
            "DEST_DB_ENV_KEY" { 
                if (($itm.value -like "PRD") -or ($itm.value -like "TST")) {
                    $itm.value = "DLV"
                }
            }
            "KIRK_DEST_DB_KEY_OVERRIDE" { 
                if (($itm.value -like "PRD") -or ($itm.value -like "TST")) {
                    $itm.value = "DLV"
                }
            }
            "FILE_CHANGE_DETECTION" {
                $itm.value = "FALSE"
            }
            Default {}
        }
    }
    $uri = $classURL + "/" + $sch.category + "/" + $sch.name
    $uri = $uri + "?" + $tokenStr
    $stBody = $sch | ConvertTo-Json -Depth $JsonDepth
    Invoke-RestMethod -Uri $uri  -Method 'PUT' -ContentType 'application/json' -Body $stBody
}

$ts = Get-Timestamp
$outFile = $dataDir + "Schedules_Updated_" + $ts + ".json"
$FMEObject | ConvertTo-Json -Depth $JsonDepth | Out-File $outFile
Write-Host "Output Updated Schedules: $outFile" 
Stop-Transcript