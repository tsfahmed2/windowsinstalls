# Download latest release from github
$Repo = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"

# --- Query the API to get the url of the zip
$APIResponse = Invoke-RestMethod -Method Get -Uri $Repo
$FileUrl = $APIResponse.assets.browser_download_url | where {$_ -match ".msixbundle"}


# --- Download the file to the current location
$fileName = "$($APIResponse.name.Replace(" ","_")).msixbundle"
$OutputPath = "$env:temp\$fileName"

if (Test-Path -Path "$((Get-Location).Path)\files\")  {
    Push-Location files
    Write-Output "Downloading $fileName ...`n"
    Invoke-RestMethod -Method Get -Uri $FileUrl -OutFile $OutputPath
} else {
    mkdir files > $null
    Push-Location files
    Write-Output "Downloading $fileName ... `n"
    Invoke-RestMethod -Method Get -Uri $FileUrl -OutFile $OutputPath
}

Write-Output "`nInstalling $fileName ...`n"
Add-AppxPackage $OutputPath
Pop-Location
refreshenv

try {
   Write-Output "Winget version is: " 
   winget --version
   Write-Output "`nWinget is installed. Try to run the 'winget' command.`n" 
} catch {
    Write-output "`nWinget is not installed. Try to install from MS Store instead`n"
}

#winget upgrade --all -h --accept-package-agreements --accept-source-agreements
