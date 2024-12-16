Start-Job -ScriptBlock { #Kinda untested
# Ensure OpenSSH Server is active
$serviceName = "sshd"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -eq $null) {
    Write-Output "OpenSSH Server service not found. Please ensure OpenSSH Server is installed."
} elseif ($service.Status -eq 'Running') {
    Write-Output "OpenSSH Server is active and running."
} else {
    Write-Output "OpenSSH Server is not running. Starting the service..."
    Start-Service -Name $serviceName
    Write-Output "OpenSSH Server has been started."
}
}