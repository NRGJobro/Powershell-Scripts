Start-Job -ScriptBlock {
# Remove SMB version 1 if it is installed
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$regName = "SMB1"

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -eq 1) {
    Write-Output "SMB version 1 is enabled. Disabling..."
    Set-ItemProperty -Path $regPath -Name $regName -Value 0
    Write-Output "SMB version 1 has been disabled."
} else {
    Write-Output "SMB version 1 is already disabled or not installed."
}
}