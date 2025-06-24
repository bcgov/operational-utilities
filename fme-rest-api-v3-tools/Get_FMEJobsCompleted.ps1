<# Name: Get_FMEJobsCompleted.ps1
Purpose:
	Download FME Completed Jobs in JSON or CSV format through FME REST API V3.

Dependencies:
	o FME_RestAPI_Common.psm1

Usage: 
	o Short form:
		Get_FMEJobsCompleted.ps1 http(s)://fmeserver abcd23er...32fg  -completedState [all/failed/success] -limit [integer] -offset [integer] -format [json/csv] -dataDir [Directory for Output] -LogFile [log file name]
	o Long form:
		Get_FMEJobsCompleted.ps1 -URL http(s)://fmeserver -token abcd23er...32fg -completedState [all/failed/success] -limit [integer] -offset [integer] -format [json/csv] -dataDir [Directory for Output] -LogFile [log file name]
Parameters:
	-URL: Mandatory. FME Server URL. eg. -URL http://fmeserver
	-token: Mandatory. FME user token. eg. -token abcd23er...32fg
	-completedState: Optional. Values: all/failed/success, defaults to "all". eg. -completedState success
	-limit: Optional. Maximum number of records to extract. Value: integer, defaults to -1, which means all records. eg. -limit 100
	-offset: Optional. Offset of the begining of the records to be extracted. Value: integer, defaults to 0. eg. -offset 500
	-format: Optional. Export file format. Values: json/csv, defaults to "json". eg. -format csv
	-dataDir: Optional. Log and data file export directory, defaults to ".\data". eg. -dataDir C:\Data\Temp
	-LogFile: Optional. Log file name, defaults to "Get_FMEJobsCompleted.log". eg. -LogFile MySession.log

Comments:
	o To enable PS Scripts, run the command below in a PowerShell window (you only need to do this once):
		Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
	o Edit $sCols list to add/remove columns.
	o If the script times out before retrieving all records, try to lower the value of Const_Limit (original value is 10000).
	o Data is exported to the $dataDir\JobsCompleted_$timestamp.[json/csv]
#>

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string][ValidateNotNullOrEmpty()]$URL,
    [Parameter(Mandatory=$true, Position=1)]
    [string][ValidateNotNullOrEmpty()]$token,
	$completedState = "all",
	$limit = -1,
	$offset = -1,
	$format = "json",
    $dataDir = (Get-Location).Path + "\data",
    $LogFile = "Get_FMEJobsCompleted.log"
)

Import-Module ./FME_RestAPI_Common.psm1

New-Variable -Name Const_Limit -Value 10000 -Option Constant

# Define columns to be extracted
# Available columns: 'request', 'timeDelivered', 'workspace', 'numErrors', 'numLines', 'engineHost', 'timeQueued', 'cpuPct', 'description', 'timeStarted', 'repository', 'userName', 'result', 'cpuTime', 'sourceType', 'id', 'sourceName', 'timeFinished', 'engineName', 'numWarnings', 'timeSubmitted', 'elapsedTime', 'peakMemUsage', 'status'
# Add available columns to the column list below:
$sCols = @('id', 'sourceType', 'sourceName', 'repository', 'workspace', 'userName', 'engineName', 'status', 'numErrors', 'timeSubmitted', 'timeQueued', 'timeStarted', 'timeFinished', 'cpuPct', 'peakMemUsage', 'elapsedTime', 'result')

function Get-TotalCount {
	param (
		[string]$classURL,
		[string]$state,
		[string]$token
	)
	$uri = $classURL + "?" + $state + "limit=1&offset=0" + $sToken
	$objFME = Invoke-RestMethod -Uri $uri  -Method 'GET' -ContentType 'application/json'
	
	return $objFME.totalCount
}

function Write-FMEObject {
	param (
		[object]$objFME,
		[string]$format
	)
	
	if ($format -like "json") {
		$FMEObject | ConvertTo-Json -Depth $JsonDepth | Add-Content -Path $outFile
	} else {
		#$iCount = 0
		foreach ($itm in $objFME.items) {
			<# Requires PowerShell >= 7.4
			if ($iCount -eq 0) {$itm | ConvertTo-Csv -NoTypeInformation $true | Out-File $outFile}
			else {$itm | ConvertTo-Csv -NoHeader $true -NoTypeInformation $true | Add-Content -Path $outFile}
			$iCount += 1
			#>
			
			$sOut = ""
			for ($i = 0; $i -lt $sCols.Count; $i++) {
				$sDelimiter = if ($i -gt 0){","}
				$sCol = $sCols[$i]
				if ($sCol -like "result") {
					$sValue = $itm.$sCol.statusMessage
				} else {
					if ($sCol.ToUpper() -in "TIMEDELIVERED", "TIMEFINISHED", "TIMEQUEUED", "TIMESTARTED", "TIMESUBMITTED") {
						$sValue = $itm.$sCol.Substring(0, 19)
						#Write-Host "column: $sCol; value: $sValue"
					} else {
						$sValue = $itm.$sCol
					}
				}
				$sQuote = if ($sCol.ToUpper() -in "NUMERRORS", "NUMLINES", "CPUPCT", "CPUTIME", "ID", "NUMWARNINGS", "ELAPSEDTIME", "PEAKMEMUSAGE") {""}
							else {"`""}
				$sOut = $sOut + $sDelimiter + $sQuote + $sValue + $sQuote
			}
			$sOut | Add-Content -Path $outFile
		}
	}
}

# Create Data Folder
if (-not (Test-Path -Path $dataDir)) {New-Item -ItemType "directory" -Path $dataDir}
if (-not ($dataDir -like "*\")) {$dataDir = $dataDir + "\"}
$LogFile = $dataDir + $LogFile
Start-Transcript -Path $LogFile -Append
# Create Output File
$ts = Get-Timestamp
$outFile = $dataDir + "JobsCompleted_" + $ts + "$completedState.$format"
# Write title line
$sOut = ""
for ($i = 0; $i -lt $sCols.Count; $i++) {
	$sDelimiter = if ($i -gt 0){","}
	$sCol = $sCols[$i]
	$sOut = $sOut + $sDelimiter + "`"" + $sCol + "`""
}
#$sOut | Out-File $outFile	# !Don't use as this insert "FF FE" at the begining of a file to signal as a Unicode format.
$sOut | Add-Content -Path $outFile

# Build REST API URL/URI
$classURL = Get-FMEClassURL $URL "transformations/jobs/completed"
$JsonDepth = Get-JsonDepth
Write-Host "Class URL: $classURL, Json Depth: $JsonDepth" 
$sToken = Get-TokenString $token
# Set completed state filter
if ($completedState -like "failed") {$sState = "completedState=failed&"}
elseif ($completedState -like "success") {$sState = "completedState=success&"}
else {$sState = ""}

# Get initial total Count
$iInitialCount = Get-TotalCount $classURL $sState $sToken
Write-Host "Total count: $iInitialCount"
# Set effective limit. When limit is not set, export all records.
$iEffectiveLimit = if ($limit -lt 1) {$iInitialCount}
			else {$limit}
# Set max limit per session
$iLimitMax = if ($limit -lt 1) {$Const_Limit}
			else {(($limit, $Const_Limit) | Measure-Object -Minimum).Minimum}
$iOffset = [System.Math]::Max(0, $offset)
while (($iOffset -lt $iEffectiveLimit) -and ($iOffset -lt $iInitialCount)) {
	$uri = $classURL + "?" + $sState + "limit=" + $iLimitMax + "&offset=" + $iOffset + $sToken
	Write-Host "Request URL: $uri"
	$FMEObject = Invoke-RestMethod -Uri $uri  -Method 'GET' -ContentType 'application/json'
	Write-FMEObject $FMEObject $format
	$iCurrentCount = Get-TotalCount $classURL $sState $sToken
	$iOffset += $iLimitMax + ($iCurrentCount - $iInitialCount)
	$iInitialCount = $iCurrentCount
}

Write-Host "Output Data File: $outFile"
Stop-Transcript

