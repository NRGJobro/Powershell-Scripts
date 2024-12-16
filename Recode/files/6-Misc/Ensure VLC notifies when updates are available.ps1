Start-Job -ScriptBlock { #Untested
# Ensure VLC notifies when updates are available
$vlcConfigPath = "$env:APPDATA\vlc\vlcrc"

if (Test-Path $vlcConfigPath) {
    (Get-Content $vlcConfigPath) -replace '^#?qt-updates-notif=.*', 'qt-updates-notif=1' | Set-Content $vlcConfigPath
    Write-Output "VLC configuration updated to notify when updates are available."
} else {
    Write-Output "VLC configuration file not found."
}
}