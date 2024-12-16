Start-Job -ScriptBlock {
# Configure the system to use FIPS 140 compliant cryptographic algorithms
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$regName = "FIPSAlgorithmPolicy"
$desiredValue = 1

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring the system to use FIPS 140 compliant cryptographic algorithms..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "The system is now configured to use FIPS 140 compliant cryptographic algorithms."
} else {
    Write-Output "The system is already configured to use FIPS 140 compliant cryptographic algorithms."
}
}