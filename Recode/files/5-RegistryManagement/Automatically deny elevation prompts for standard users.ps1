Start-Job -ScriptBlock {
# Automatically deny elevation prompts for standard users
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regName = "ConsentPromptBehaviorUser"
$desiredValue = 0

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Automatically denying elevation prompts for standard users..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Elevation prompts for standard users are now automatically denied."
} else {
    Write-Output "Elevation prompts for standard users are already automatically denied."
}
}