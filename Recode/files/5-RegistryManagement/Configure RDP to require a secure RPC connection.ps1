Start-Job -ScriptBlock {
# Configure RDP to require a secure RPC connection
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$regName = "UserAuthentication"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring RDP to require a secure RPC connection..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "RDP is now configured to require a secure RPC connection."
} else {
    Write-Output "RDP is already configured to require a secure RPC connection."
}
}