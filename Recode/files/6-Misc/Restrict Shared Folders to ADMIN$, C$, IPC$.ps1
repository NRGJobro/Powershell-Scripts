Start-Job -ScriptBlock {
    Get-SmbShare | Where-Object { $_.Name -notin @("ADMIN$", "C$", "IPC$") } | Remove-SmbShare -Force
}