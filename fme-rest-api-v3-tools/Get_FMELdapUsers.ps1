<# Name: Get_FMELdapUsers.ps1
Purpose: Download FME Ldap Users in JSON format through FME API.
Usage:
- Short form: Get_FMELdapUsers.ps1 http(s)://fmeserver abcd23er...32fg
- Long form: Get_FMELdapUsers -URL http(s)://fmeserver -token abcd23er...32fg -dataDir [Directory for Output]
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
    $LogFile = "Get_FMELdapUsers.log"
)

Import-Module ./FME_RestAPI_Common.psm1

# Create Data Folder
if (-not (Test-Path -Path $dataDir)) {New-Item -ItemType "directory" -Path $dataDir}
if (-not ($dataDir -like "*\")) {$dataDir = $dataDir + "\"}
$LogFile = $dataDir + $LogFile
Start-Transcript -Path $LogFile -Append
$ts = Get-Timestamp
$outFile = $dataDir + "LDAP_Users_" + $ts + ".json"
# Build REST API URL/URI
$classURL = Get-FMEClassURL $URL "security/accounts"
$JsonDepth = Get-JsonDepth
Write-Host "Class URL: $classURL, Json Depth: $JsonDepth" 
$tokenStr = Get-TokenString $token
$uri = $classURL + "?limit=-1&offset=-1&summary=true" + $tokenStr
Write-Host "Request URL: $uri"
$method = "GET"
$FMEObject = Invoke-RestMethod -Uri $uri  -Method $method -ContentType 'application/json'
Write-Debug $FMEObject.totalCount
Add-Content -Path $outFile -Value "{`n    ""items"":  [`n"
$iCount = 0
foreach ($itm in $FMEObject.items) {
    if ($itm.type -like "Ldap*") {
        $uri = $classURL + "/" + $itm.name + "/ldap?" + $tokenStr
        $account = Invoke-RestMethod -Uri $uri  -Method $method -ContentType 'application/json'
        if ($iCount -gt 0) {
            Add-Content -Path $outFile -Value ','
        }
        $iCount += 1
        $account | ConvertTo-Json -Depth $JsonDepth | Add-Content -Path $outFile
    }
}
Add-Content -Path $outFile -Value "    ],`n   ""totalCount"":  $iCount}"
Write-Host "Output File: $outFile" 
Stop-Transcript

