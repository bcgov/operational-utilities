<# Name: Get_FMEUsers.ps1
Purpose: Download FME Users (Accounts) in JSON format through FME API.
Usage:
- Short form: Get_FMEUsers.ps1 http(s)://fmeserver abcd23er...32fg
- Long form: Get_FMEUsers -URL http(s)://fmeserver -token abcd23er...32fg -dataDir [Directory for Output]
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
    $LogFile = "Get_FMEUsers.log"
)

Import-Module ./FME_RestAPI_Common.psm1

# Create Data Folder
if (-not (Test-Path -Path $dataDir)) {New-Item -ItemType "directory" -Path $dataDir}
if (-not ($dataDir -like "*\")) {$dataDir = $dataDir + "\"}
$LogFile = $dataDir + $LogFile
Start-Transcript -Path $LogFile -Append
$ts = Get-Timestamp
$outFile = $dataDir + "Users_" + $ts + ".json"
# Build REST API URL/URI
$classURL = Get-FMEClassURL $URL "security/accounts"
$JsonDepth = Get-JsonDepth
Write-Host "Class URL: $classURL, Json Depth: $JsonDepth" 
$tokenStr = Get-TokenString $token
$uri = $classURL + "?limit=-1&offset=-1&summary=true" + $tokenStr
Write-Host "Request URL: $uri"
# Get FME Users (Accounts)
$FMEObject = Invoke-RestMethod -Uri $uri  -Method 'GET' -ContentType 'application/json'
$FMEObject | ConvertTo-Json -Depth $JsonDepth | Out-File $outFile
Write-Host "Output Data File: $outFile" 
Stop-Transcript