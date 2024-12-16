Start-Job -ScriptBlock {
# Enable file and registry write failure virtualization to per-user locations
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$desiredValue = "RUNASINVOKER"

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

Write-Output "Enabling virtualization for file and registry write failures to per-user locations..."
Set-ItemProperty -Path $regPath -Name "*" -Value $desiredValue
Write-Output "File and registry write failures are now virtualized to per-user locations."
}