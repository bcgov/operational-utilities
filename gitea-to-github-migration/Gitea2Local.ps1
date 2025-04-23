<# Gitea2Local.ps1
# Purpose: Batch download Gitea repos to your local drive based on the list in a CSV file.
# Usage: .\Gitea2Local.ps1 -GiteaWebsite [https://your.gitea.com] -GiteaUser [Your user ID] -GiteaToken [Your Gitea token] -GiteaRepoList [GiteaRepoList.csv] -Mirror [true/false]
# * GiteaRepoList is a comma separated value file with two tuples per row: gitea_org, gitea_repo. If the file has more than two tuples, the rest tuples are ignored.
# ** Use '#' to comment out lines in GiteaRepoList.csv
# *** If Readme.md is missing from a repo, the script will create one based on the gitea repo description.
#
# Set the policy to enable PS Scripts:
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#>
param (
    $GiteaWebsite = $(throw "GiteaWebsite is required."),
    $GiteaUser = $(throw "GiteaUser is required."),
    $GiteaToken = $(throw "Giteatoken is required."),
    $GiteaRepoList = ".\Gitea_repo_list.txt",
	$Mirror = $false
)

function Get-Timestamp() {
    Return (Get-Date -Format "[yyyy-MM-dd HH:mm:ss]")
}

$logFile=(Get-Location).Path + "\GiteaDownload_" + (Get-Date -Format "yyyy-MM-dd-HHmm") + ".log"
Start-Transcript -Path $logFile -Append
Write-Host "**********************`n"
Write-Host "`n"

$file=Get-Content $GiteaRepoList
foreach ($line in $file) {
    $Params=$line.Split(',')
    $giteaOrg=$Params[0].Trim()
    
    if (($giteaOrg.Length -gt 0) -And ($giteaOrg.SubString(0, 1) -ne "#" ) -And ($Params.Length -gt 1)) {
        $giteaRepo=$Params[1].Trim()
        
        # Get Gitea description
        $jsonFilePath=".\GiteaHeading.json"
        $repo="$GiteaWebsite/api/v1/repos/$giteaOrg/$giteaRepo"
        $ts=Get-Timestamp
        Write-Host "$ts Processing: $repo"
        $ts=Get-Timestamp
        Write-Host "$ts Download meta data:"
        $GitLogin="$GiteaUser" + ":$GiteaToken"
        & curl.exe -X GET $repo -H "accept: application/json" -u $GitLogin -o $jsonFilePath
        $jsonData=Get-Content -Path $jsonFilePath | ConvertFrom-json
        $desc=$jsonData.description
        
        # Get Gitea repo
        $repo= "$GiteaWebsite/$giteaOrg/$giteaRepo.git"
        $ts=Get-Timestamp
        if ($Mirror) {
            #git clone --mirror "$GiteaWebsite/$giteaOrg/$giteaRepo.git" | Tee-Object -Variable cmdOutput
            Write-Host "$ts download_repo: git clone --mirror $repo"
            git clone --mirror $repo
        } else {
            Write-Host "$ts download_repo: git clone $repo"
            git clone $repo
        }
        #Test-Output -Msg $cmdOutput -File $logFile

        if ($?) {
            Push-Location
            Set-Location .\$giteaRepo.git
            # Create readme.md if it is missing
            if (-not(Test-Path -Path .README.md -PathType Leaf)) {
                $null = New-Item -ItemType File -Path .\README.md -Force
                Write-Host Write description into readme.md
                Write-Output $desc > README.md
            }
            Pop-Location
        }
        Write-Host `n
    }
}

# Remove temporary jason file
# if (Test-Path -Path $jsonFilePath -PathType Leaf) {Remove-Item $jsonFilePath}

Stop-Transcript
