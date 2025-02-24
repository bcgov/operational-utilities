<# Gitea2GitHub.ps1
# Purpose: Batch migrating Gitea repos to github based on the list in a CSV file.
# Usage: .\Gitea2GitHub.ps1 -GiteaWebsite [https://your.gitea.com] -GiteaUser [Your user ID] -GiteaToken [Your Gitea token] -GiteaRepoList [GiteaRepoList.csv] -RepoSuffix [Optional github repo suffix] -Mirror [Optional $true or $false]
#
# * GiteaRepoList.csv is a comma separated value file with five tuples per row:
# *      Gitea_Org, Gitea_Repo, GitHub_Org, GitHub_Repo, (Optional)GitHub_ServiceAccount
# * - Use '#' to comment out lines in GiteaRepoList.csv
# * - If GitHub_ServiceAccount is provided, the script will grant Read access to the account.
#
# ** If the Optional github repo suffix is provided, the new GitHub repo will be:  GitHub_Repo-RepoSuffix
# *** If Readme.md is missing from a repo, the script will create one based on the gitea repo description.
#
# Set the policy to enable PS Scripts:
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#>
param (
    $GiteaWebsite = $(throw "GiteaWebsite is required."),
    $GiteaUser = $(throw "GiteaUser is required."),
    $GiteaToken = $(throw "Giteatoken is required."),
    $GiteaRepoList = $(throw "GiteaRepo text file is required."),
    $RepoSuffix = "",
	$Mirror = $false
)

function Get-Timestamp() {
    Return (Get-Date -Format "[yyyy-MM-dd HH:mm:ss]")
}

$wkPath=(Get-Location).Path
$jsonFilePath="$wkPath\GiteaHeading.json"
$logPath="$wkPath\Logs"
if (-not(Test-Path -Path $logPath)) {$null = New-Item -ItemType Path -Path $logPath -Force}
$logFile="$logPath\Gitea2Git_" + (Get-Date -Format "yyyy-MM-dd-HHmm") + ".log"
Start-Transcript -Path $logFile -Append
Write-Host "**********************`n"
Write-Host "`n"

# define variables
$giteaOrg=""
$giteaRepo=""
$gitOrg=""
$gitRepo=""
$GitServiceAccount=""

# processing repo list file
$file=Get-Content $GiteaRepoList
foreach ($line in $file) {
    $Params=$line.Split(',')
    $giteaOrg=$Params[0].Trim()
    
    if (($giteaOrg.Length -gt 0) -And ($giteaOrg.SubString(0, 1) -ne "#" ) -And ($Params.Length -gt 3)) {
		$giteaRepo=$Params[1].Trim()
		$GitOrg=$Params[2].Trim()
        $gitRepo=$Params[3].Trim()
		if ($RepoSuffix -ne "") {
			$gitRepo="$gitRepo-" + $RepoSuffix.Trim()
		}
        if ($Params.Length -gt 4) {
            $GitServiceAccount=$Params[4].Trim()
        } else {
            $GitServiceAccount=""
        }
        $ts=Get-Timestamp
		Write-Host "========================================================="
        Write-Host "$ts Processing: $giteaOrg/$giteaRepo"
		Write-Host "========================================================="
    
        # Get Gitea description
        $repo="$GiteaWebsite/api/v1/repos/$giteaOrg/$giteaRepo"
        $ts=Get-Timestamp
        Write-Host "$ts Processing: $repo"
        $ts=Get-Timestamp
        Write-Host "$ts Download meta data: curl.exe -X GET $repo -H `"accept: application/json`" -u user:pwd -o $jsonFilePath"
        $GitLogin="$GiteaUser" + ":$GiteaToken"
        & curl.exe -X GET $repo -H "accept: application/json" -u $GitLogin -o $jsonFilePath
        $jsonData=Get-Content -Path $jsonFilePath | ConvertFrom-json
        $desc=$jsonData.description
        
		# Get Gitea repo
        $repo= "$GiteaWebsite/$giteaOrg/$giteaRepo.git"
        $ts=Get-Timestamp
		if ($Mirror) {
  			Write-Host "$ts download_repo: git clone --mirror $repo"
			git clone --mirror $repo
		} else {
  			Write-Host "$ts download_repo: git clone $repo"
			git clone $repo
		}
        if ($?) {
            Push-Location
			if ($Mirror) {
				Set-Location .\$giteaRepo.git
			} else {
				Set-Location .\$giteaRepo
			}
            # Create readme.md if it is missing
            if (-not(Test-Path -Path .\README.md -PathType Leaf)) {$null = New-Item -ItemType File -Path .\README.md -Force}

            # Create github repo and grant $GitServiceAccount Read access to the repo
            $repo="$GitOrg/$gitRepo"
            $ts=Get-Timestamp
            if ($GitServiceAccount -eq "") {
                if ($desc -eq "") {
		    Write-Host "$ts create_github_repo: gh repo create $repo --private"
                    gh repo create $repo --private 
                } else {
		    Write-Host "$ts create_github_repo: gh repo create $repo --private --description `"$desc`""
                    gh repo create $repo --private --description "$desc"
                }
            } else {
                if ($desc -eq "") {
        	    Write-Host "$ts create_github_repo: gh repo create $repo --private --team `"$GitServiceAccount`""
	            gh repo create $repo --private --team "$GitServiceAccount"
                } else {
		    Write-Host "$ts create_github_repo: gh repo create $repo --private --team `"$GitServiceAccount`" --description `"$desc`""
                    gh repo create $repo --private --team "$GitServiceAccount" --description "$desc"
                }
            }

            # Clone to github
            $repo="https://github.com/$GitOrg/$gitRepo"
            $ts=Get-Timestamp
			if ($Mirror) {
   				Write-Host "$ts push to github repo: git push --mirror $repo"
				git push --mirror $repo
			} else {
   				Write-Host "$ts push to github repo: git push $repo"
				git push $repo
			}

            # Clean up temporary folder
            Pop-Location
			if ($Mirror) {
                $ts=Get-Timestamp
                Write-Host "$ts delete temporary folder: Remove-Item .\$giteaRepo.git -Recurse -Force"
				Remove-Item .\$giteaRepo.git -Recurse -Force
			} else {
				# keep the repo, update it with Git GUI (Jenkinsfile, delete Secrets folder commit and then add Secrets folder and secrets, delete .gitModules; commit. Remove 'Origin', add GitHub as 'Origin'; push.
				# Remove-Item .\$giteaRepo -Recurse -Force
			}
        }
        Write-Host `n
    }
}

# Remove temporary jason file
if (Test-Path -Path $jsonFilePath -PathType Leaf) {Remove-Item $jsonFilePath}

Stop-Transcript
