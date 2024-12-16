Start-Job -ScriptBlock {
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\System"
$regNameSmartScreen = "EnableSmartScreen"
$regNameBypass = "ConfigureAppInstallControl"
$desiredValueSmartScreen = 1
$desiredValueBypass = 2

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

# Enable SmartScreen
$currentValueSmartScreen = Get-ItemProperty -Path $regPath -Name $regNameSmartScreen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regNameSmartScreen -ErrorAction SilentlyContinue
if ($currentValueSmartScreen -ne $desiredValueSmartScreen) {
    Write-Output "Enabling Defender SmartScreen to require administrator approval for unknown software..."
    Set-ItemProperty -Path $regPath -Name $regNameSmartScreen -Value $desiredValueSmartScreen
    Write-Output "Defender SmartScreen is now enabled to require administrator approval for unknown software."
} else {
    Write-Output "Defender SmartScreen is already configured to require administrator approval for unknown software."
}

# Prevent bypassing SmartScreen
$currentValueBypass = Get-ItemProperty -Path $regPath -Name $regNameBypass -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regNameBypass -ErrorAction SilentlyContinue
if ($currentValueBypass -ne $desiredValueBypass) {
    Write-Output "Configuring Defender SmartScreen to prevent bypassing attempts for unknown software..."
    Set-ItemProperty -Path $regPath -Name $regNameBypass -Value $desiredValueBypass
    Write-Output "Defender SmartScreen is now configured to prevent bypassing attempts for unknown software."
} else {
    Write-Output "Defender SmartScreen is already configured to prevent bypassing attempts for unknown software."
}
}