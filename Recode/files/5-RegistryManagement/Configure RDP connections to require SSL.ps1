Start-Job -ScriptBlock {
# Configure RDP connections to require SSL
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$regName = "SecurityLayer"
$desiredValue = 2

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring RDP connections to require SSL..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "RDP connections are now configured to require SSL."
} else {
    Write-Output "RDP connections are already configured to require SSL."
}
}