Start-Job -ScriptBlock {
    if (Get-Service -Name "FTPSVC" -ErrorAction SilentlyContinue) {
        Stop-Service -Name "FTPSVC" -Force
        Set-Service -Name "FTPSVC" -StartupType Disabled
        Write-Output "FTP service stopped and disabled."
    } else {
        Write-Output "FTP service not found."
    }
}