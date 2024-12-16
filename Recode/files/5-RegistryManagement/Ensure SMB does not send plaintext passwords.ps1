Start-Job -ScriptBlock {
# Ensure SMB does not send plaintext passwords
$regPathWorkstation = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$regNamePlaintextPassword = "EnablePlainTextPassword"
$desiredValue = 0

$currentValue = Get-ItemProperty -Path $regPathWorkstation -Name $regNamePlaintextPassword -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regNamePlaintextPassword -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring SMB to not send plaintext passwords..."
    Set-ItemProperty -Path $regPathWorkstation -Name $regNamePlaintextPassword -Value $desiredValue
    Write-Output "SMB is now configured to not send plaintext passwords."
} else {
    Write-Output "SMB is already configured to not send plaintext passwords."
}
}