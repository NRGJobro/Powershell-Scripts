Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regName = "NoConnectedUser"
$desiredValue = 3

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring system to prevent users from adding or logging on with Microsoft accounts..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "System is now configured to prevent users from adding or logging on with Microsoft accounts."
} else {
    Write-Output "System is already configured to prevent users from adding or logging on with Microsoft accounts."
}

}