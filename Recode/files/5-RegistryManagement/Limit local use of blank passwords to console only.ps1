Start-Job -ScriptBlock {
Write-Output "Ensuring local use of blank passwords is limited to console logon only..."
try {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -Value 1 -ErrorAction Stop
    Write-Output "Local use of blank passwords limited to console logon only."
} catch {
    Write-Output "Failed to set policy to limit local use of blank passwords. Please check permissions or try running PowerShell as an administrator."
}
}