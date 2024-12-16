Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
$regName = "NoToastApplicationNotificationOnLockScreen"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Disabling app notifications on the lock screen..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "App notifications are now disabled on the lock screen."
} else {
    Write-Output "App notifications are already disabled on the lock screen."
}
}