Start-Job -ScriptBlock {
    Set-Service -Name "SNMPTRAP" -StartupType Disabled
    Stop-Service -Name "SNMPTRAP" -Force
}