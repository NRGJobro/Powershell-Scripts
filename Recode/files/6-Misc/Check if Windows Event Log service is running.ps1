Start-Job -ScriptBlock {
$serviceName = "eventlog"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -and $service.Status -eq 'Running') {
    Write-Output "Windows Event Log service is running."
} elseif ($service -and $service.StartType -eq 'Disabled') {
    Write-Output "Windows Event Log service is disabled. Enabling the service..."
    Set-Service -Name $serviceName -StartupType Automatic
    Start-Service -Name $serviceName
    Write-Output "Windows Event Log service has been enabled and started."
} else {
    Write-Output "Windows Event Log service is not running. Starting the service..."
    Start-Service -Name $serviceName
    Write-Output "Windows Event Log service has been started."
}
}