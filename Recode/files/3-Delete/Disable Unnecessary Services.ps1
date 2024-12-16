Start-Job -ScriptBlock {
    Write-Output "Disabling unnecessary services..."
    $servicesToDisable = @(
        "RemoteRegistry",
        "Telnet",
        "SNMP",
        "Fax",
        "wuauserv"  # Windows Update Service (if not required)
    )
    foreach ($service in $servicesToDisable) {
        try {
            Set-Service -Name $service -StartupType Disabled -ErrorAction Stop
            Stop-Service -Name $service -Force -ErrorAction Stop
            Write-Output "Service '$service' has been disabled and stopped."
        } catch {
            Write-Output "Failed to disable service '$service': $($_.Exception.Message)"
        }
    }
    Write-Output "Unnecessary services have been disabled."
}