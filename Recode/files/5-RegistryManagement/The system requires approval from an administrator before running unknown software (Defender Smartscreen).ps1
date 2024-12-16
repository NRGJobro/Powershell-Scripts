Start-Job -ScriptBlock {
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\System"
$regName = "EnableSmartScreen"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Enabling Defender SmartScreen to require administrator approval for unknown software..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Defender SmartScreen is now enabled to require administrator approval for unknown software."
} else {
    Write-Output "Defender SmartScreen is already configured to require administrator approval for unknown software."
}
}