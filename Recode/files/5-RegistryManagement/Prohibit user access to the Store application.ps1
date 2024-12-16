Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
$regName = "RemoveWindowsStore"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Prohibiting user access to the Store application..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "User access to the Store application is now prohibited."
} else {
    Write-Output "User access to the Store application is already prohibited."
}
}