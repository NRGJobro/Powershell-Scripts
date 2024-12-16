Start-Job -ScriptBlock {
    Write-Output "Setting RDP Security Layer to SSL..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer" -Value 2
    Write-Output "RDP Security Layer set to SSL."
}