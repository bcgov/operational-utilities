<# Name: FME_RestAPI3_Common.psm1
# Purpose: Common FME Rest API Call Functions
# Comment:
#  - FME REST API Version: V3
#  - Use of "offset" and "limit":
#    * "offset":  -1 means not set. Offset starts from 0. The largest offset should be less than the "totalCount".
#    * "limit":  -1 means not set. It sets the limit of number of items to retrieve. If it is too big, the script returns an error. In case of Jobs Completed, 10,000 is acceptable.
#    * "totalCount":  47,304 is the total number of items.
#    * "offset" and "limit" must be used together. Be aware that a same offset between two runs could point to different records since new records could be added since the last run.

# Set the policy to enable PS Scripts:
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

#>

New-Variable -Name ApiBase -Value "fmerest/v3/" -Option Constant
New-Variable -Name JsonDepth -Value 12 -Option Constant

<#
# FME REST API Clases:
"automations/workflows"
"automations/workflows/tags"
"cleanup/configuration"
"cleanup/tasks"
"healthcheck"
"info"
"metrics"
"notifications/publications"
"notifications/publishers"
"notifications/subscribers"
"notifications/subscriptions"
"notifications/topics"
"projects/import/resource"
"projects/import/upload"
"projects/itemtypes"
"projects/projects"
"repositories"
"resources/connections"
"resources/directdownloadurlparameters"
"resources/directuploadurlparameters"
"resources/types"
"schedules"
"schedules/categories"
"security/accounts"
"security/categories"
"security/ldap"
"security/roles"
"systemevents/events/completed"
"transformations/jobs/completed"
#>

function Get-FMEClassURL {
    param (
        [string]$URL,
        [string]$class
    )
    
    if (-not ($URL -like "*/")) {$URL = $URL + "/"}
    #Write-Debug "$class"
    $classURL = $URL + $ApiBase + $class
    return $classURL
}

function Get-JsonDepth {
    return $JsonDepth
}

function Get-Timestamp {
    $strTimestamp = Get-Date -Format "yyyy-MM-dd-HHmm-ssffff"
    return $strTimestamp
}

function Get-TokenString {
    param (
        [string]$token
    )
    
    $str = "&fmetoken=" + $token
    return $str
}

function Get-UserRoles {
    param (
        [string]$URL,
        [string]$token,
        [string]$outFile
    )
    
    $class = "security/accounts"
	$uriClass = Get-FMEClassURL $URL $class
	$tokenStr = Get-TokenString $token
    $uri = $uriClass + "?limit=-1&offset=-1&summary=true" + $tokenStr
    Write-Host "Request URL: $uri"
    $FMEObject = Invoke-RestMethod -Uri $uri  -Method 'GET' -ContentType 'application/json'
    Write-Debug $FMEObject.totalCount
    Add-Content -Path $outFile -Value "{`n    ""items"":  [`n"
    $iCount = 0
    foreach ($itm in $FMEObject.items) {
        $uri = $uriClass + "/" + $itm.name + "/roles?" + $tokenStr
        $account = Invoke-RestMethod -Uri $uri  -Method 'GET' -ContentType 'application/json'
        if ($iCount -gt 0) {
            Add-Content -Path $outFile -Value ','
        }
        $iCount += 1
        $account | ConvertTo-Json -Depth $JsonDepth | Add-Content -Path $outFile
    }
    Add-Content -Path $outFile -Value "    ],`n   ""totalCount"":  $iCount}"
}

function Set-UserRoles {
    param (
        [string]$URL,
        [string]$token,
        [string]$userRoles
    )

    # Get FME User Roles to Be Updated
    $FMEObject = Get-Content -Path $userRoles | ConvertFrom-Json
    $class = "security/accounts"
	$uriClass = Get-FMEClassURL $URL $class
	$tokenStr = Get-TokenString $token
    $hdr = "roles="
    $iCount = 0
    foreach ($itm in $FMEObject.items) {
        $rls = $hdr
        foreach ($usrRls in $itm) {
            if ($usrRls -like "user:*") {$usr = $usrRls.Split(":")[-1]}
            else {
                if (-not ($rls -eq $hdr)) {$rls = $rls + "&$hdr"}
                $rls = $rls + $usrRls
            }
        }
        if (-not ($rls -eq $hdr)) {
            $uri = $uriClass + "/" + $usr + "/roles?" + $tokenStr
            Invoke-RestMethod -Uri $uri  -Method 'PUT' -ContentType 'application/x-www-form-urlencoded' -Body $rls
            $iCount += 1
        }
    }
    Write-Host "$iCount User Roles have updated."
}

