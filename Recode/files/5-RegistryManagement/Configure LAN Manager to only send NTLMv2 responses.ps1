Start-Job -ScriptBlock {
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$regName = "LmCompatibilityLevel"
$desiredValue = 5

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Setting LAN Manager to only send NTLMv2 responses..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "LAN Manager is now configured to only send NTLMv2 responses."
} else {
    Write-Output "LAN Manager is already configured to only send NTLMv2 responses."
}
}