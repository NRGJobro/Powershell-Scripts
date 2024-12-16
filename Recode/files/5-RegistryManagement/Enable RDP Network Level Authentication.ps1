Start-Job -ScriptBlock {
    Write-Output "Enabling RDP Network Level Authentication..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1
    Write-Output "RDP Network Level Authentication enabled."
}