Start-Job -ScriptBlock {
$bittorrentName = "BitTorrent"

# Check if BitTorrent is running
$bittorrentProcess = Get-Process -Name "bittorrent" -ErrorAction SilentlyContinue

if ($bittorrentProcess) {
    Write-Output "Stopping BitTorrent process..."
    Stop-Process -Name "bittorrent" -Force
    Write-Output "BitTorrent process has been stopped."
}

# Attempt to uninstall BitTorrent from AppData\Roaming
$bittorrentPath = "$env:APPDATA\BitTorrent"

if (Test-Path -Path "$bittorrentPath") {
    Write-Output "Found BitTorrent in AppData\Roaming. Removing..."
    Remove-Item -Path "$bittorrentPath" -Recurse -Force
    Write-Output "BitTorrent has been removed successfully."
}

if (-not (Get-Process -Name "bittorrent" -ErrorAction SilentlyContinue)) {
    Write-Output "BitTorrent is not installed or has been successfully removed."
} else {
    Write-Output "BitTorrent could not be uninstalled or was not found."
}
}