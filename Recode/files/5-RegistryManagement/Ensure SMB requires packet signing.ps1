Start-Job -ScriptBlock {
# Ensure SMB requires packet signing
$regPathServer = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$regNameServer = "EnableSecuritySignature"
$desiredValueServer = 1

$regPathWorkstation = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$regNameWorkstation = "EnableSecuritySignature"
$desiredValueWorkstation = 1

# Configure SMB Server to require packet signing
$currentValueServer = Get-ItemProperty -Path $regPathServer -Name $regNameServer -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regNameServer -ErrorAction SilentlyContinue

if ($currentValueServer -ne $desiredValueServer) {
    Write-Output "Configuring SMB Server to require packet signing..."
    Set-ItemProperty -Path $regPathServer -Name $regNameServer -Value $desiredValueServer
    Write-Output "SMB Server is now configured to require packet signing."
} else {
    Write-Output "SMB Server is already configured to require packet signing."
}

# Configure SMB Workstation to require packet signing
$currentValueWorkstation = Get-ItemProperty -Path $regPathWorkstation -Name $regNameWorkstation -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regNameWorkstation -ErrorAction SilentlyContinue

if ($currentValueWorkstation -ne $desiredValueWorkstation) {
    Write-Output "Configuring SMB Workstation to require packet signing..."
    Set-ItemProperty -Path $regPathWorkstation -Name $regNameWorkstation -Value $desiredValueWorkstation
    Write-Output "SMB Workstation is now configured to require packet signing."
} else {
    Write-Output "SMB Workstation is already configured to require packet signing."
}
}