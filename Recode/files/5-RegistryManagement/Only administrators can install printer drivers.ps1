Start-Job -ScriptBlock {
$regPath = "HKLM:\Software\Policies\Microsoft\Windows NT\Printers"
$regName = "RestrictDriverInstallationToAdministrators"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Restricting printer driver installation to administrators only..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Printer driver installation is now restricted to administrators only."
} else {
    Write-Output "Printer driver installation is already restricted to administrators only."
}

}