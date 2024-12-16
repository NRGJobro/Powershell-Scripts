Start-Job -ScriptBlock {
    Write-Output "Configuring Windows Firewall settings to default..."
    netsh advfirewall reset
    Write-Output "Windows Firewall settings have been reset to default."
}