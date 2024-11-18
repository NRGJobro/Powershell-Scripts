Start-Job -ScriptBlock {
    if (Get-Service -Name "W3SVC" -ErrorAction SilentlyContinue) {
        Stop-Service -Name "W3SVC" -Force
        Set-Service -Name "W3SVC" -StartupType Disabled
        Write-Output "WWW Publishing service stopped and disabled."
    } else {
        Write-Output "WWW Publishing service not found."
    }
}