Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regName = "DisableCredMgrAccess"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring system to prevent access to Credential Manager as a trusted caller..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "System is now configured to prevent access to Credential Manager as a trusted caller."
} else {
    Write-Output "System is already configured to prevent access to Credential Manager as a trusted caller."
}

}