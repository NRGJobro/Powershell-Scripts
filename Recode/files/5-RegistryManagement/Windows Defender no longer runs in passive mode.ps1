Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$regName = "ForceDefenderPassiveMode"
$desiredValue = 0

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Disabling passive mode for Windows Defender..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Windows Defender is no longer running in passive mode."
} else {
    Write-Output "Windows Defender is already configured to not run in passive mode."
}

}