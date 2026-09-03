<# Name: Multi_Clone_File.ps1
Purpose:
    Make multiple copies of one file.

Usage:
	o Short form:
        Multi_Clone_File.ps1 "full_name_of_file" start_number end_number -divider "-"
	o Long form:
        Multi_Clone_File.ps1 -fileName "full_name_of_file" -start start_number -end end_number -divider "-"
Parameters:
    -fileName: Mandatory. Include the extension. If not in the current folder, include the whole path.
    -start: Mandatory. The number to be inserted into the name of the first cloned file.
    -end: Mandatory. The number to be inserted into the name of the last cloned file.
    -divider: Optional. Typically is a dash "-" or a underscore "_", defaults to none.
Example:
    Multi_Clone_File.ps1 FME_CompletedJobs.fmw 0 3 -divider "-"
    Will clone FME_CompletedJobs.fmw to
        FME_CompletedJobs-0.fmw
        FME_CompletedJobs-1.fmw
        FME_CompletedJobs-2.fmw
        FME_CompletedJobs-3.fmw
Comments:
	o To enable PS Scripts, run the command below in a PowerShell window (you only need to do this once):
		Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#>

param (
    [Parameter(Mandatory=$true, Position=0)]
    [string][ValidateNotNullOrEmpty()]$fileName,
    [Parameter(Mandatory=$true, Position=1)]
    [int16][ValidateNotNullOrEmpty()]$start,
    [Parameter(Mandatory=$true, Position=2)]
    [int16][ValidateNotNullOrEmpty()]$end,
    $divider = ""
)

$name = $fileName.Substring(0, $fileName.LastIndexOf("."))
$ext = $fileName.Substring($fileName.LastIndexOf("."))

for ($counter = $start; $counter -le $end; $counter++) {
    $dest = $name + $divider + $counter + $ext
    Write-Host $dest
    Copy-Item -Path $fileName -Destination $dest
}
