Start-Job -ScriptBlock {
    Set-Service -Name "MpsSvc" -StartupType Automatic
    Start-Service -Name "MpsSvc"
}