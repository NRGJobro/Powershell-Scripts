Start-Job -ScriptBlock {
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl"
$regName = "CrashDumpEnabled"
$desiredValue = 0

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Disabling core dumps on system crash..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Core dumps are now disabled on system crash."
} else {
    Write-Output "Core dumps are already disabled on system crash."
}

}