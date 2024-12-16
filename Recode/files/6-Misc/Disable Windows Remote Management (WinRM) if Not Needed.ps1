Start-Job -ScriptBlock {
    Write-Output "Disabling Windows Remote Management (WinRM) if not needed..."
    try {
        # Disable WinRM service
        Set-Service -Name "WinRM" -StartupType Disabled -ErrorAction Stop
        Stop-Service -Name "WinRM" -Force -ErrorAction Stop
        Write-Output "Windows Remote Management (WinRM) service disabled."
    } catch {
        Write-Output "Failed to disable WinRM service: $($_.Exception.Message)"
    }
    Write-Output "WinRM service configuration completed."
}