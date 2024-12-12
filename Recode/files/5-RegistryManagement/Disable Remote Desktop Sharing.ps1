Start-Job -ScriptBlock {
    # Turn off Remote Desktop Sharing

    # Disable Remote Desktop service
    Set-Service -Name "TermService" -StartupType Disabled
    Stop-Service -Name "TermService" -Force
    Write-Output "Remote Desktop service disabled and stopped."

    # Ensure Remote Desktop is turned off in system settings
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1
    Write-Output "Remote Desktop connections have been disabled in system settings."

    # Verify the settings
    $rdpStatus = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
    if ($rdpStatus.fDenyTSConnections -eq 1) {
        Write-Output "Remote Desktop is successfully disabled."
    } else {
        Write-Output "Failed to disable Remote Desktop."
    }
}