Start-Job -ScriptBlock {
$serviceName = "wuauserv"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -and $service.Status -eq 'Running') {
    Write-Output "Windows Update service is running."
} else {
    Write-Output "Windows Update service is not running. Starting the service..."
    Start-Service -Name $serviceName
    Write-Output "Windows Update service has been started."
}
}