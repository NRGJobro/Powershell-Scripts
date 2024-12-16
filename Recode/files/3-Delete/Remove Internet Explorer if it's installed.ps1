Start-Job -ScriptBlock {
$ieProcess = Get-Process -Name "iexplore" -ErrorAction SilentlyContinue

if ($ieProcess) {
    Write-Output "Internet Explorer is running. Stopping process..."
    Stop-Process -Name "iexplore" -Force
    Write-Output "Internet Explorer process has been stopped."
}

# Remove Internet Explorer if it's installed
$features = Get-WindowsOptionalFeature -Online | Where-Object {$_.FeatureName -eq "Internet-Explorer-Optional-amd64"}

if ($features.State -eq "Enabled") {
    Write-Output "Internet Explorer is installed. Removing..."
    Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart
    Write-Output "Internet Explorer has been removed."
} elseif ($features.State -eq "Disabled") {
    Write-Output "Internet Explorer is already removed."
} else {
    Write-Output "Internet Explorer is not found on this system."
}
}