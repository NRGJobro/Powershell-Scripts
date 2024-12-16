Start-Job -ScriptBlock {
# Ensure UPnP is not enabled
$regPath = "HKLM:\SOFTWARE\Microsoft\DirectPlayNATHelp\DPNHUPnP"
$regName = "UPnPMode"
$desiredValue = 0

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Disabling UPnP..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "UPnP has been disabled."
} else {
    Write-Output "UPnP is already disabled."
}
}