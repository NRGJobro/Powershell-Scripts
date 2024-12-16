Start-Job -ScriptBlock {
    Set-Service -Name "upnphost" -StartupType Disabled
    Stop-Service -Name "upnphost" -Force
}