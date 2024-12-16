Start-Job -ScriptBlock { #Untested
# Ensure FileZilla Server is active
$serviceName = "FileZilla Server"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -eq $null) {
    Write-Output "FileZilla Server service not found. Please ensure FileZilla Server is installed."
} elseif ($service.Status -eq 'Running') {
    Write-Output "FileZilla Server is active and running."
} else {
    Write-Output "FileZilla Server is not running. Starting the service..."
    Start-Service -Name $serviceName
    Write-Output "FileZilla Server has been started."
}
}