Start-Job -ScriptBlock {
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$regName = "RestrictAnonymous"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Prohibiting NULL session fallback..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "NULL session fallback is now prohibited."
} else {
    Write-Output "NULL session fallback is already prohibited."
}

}