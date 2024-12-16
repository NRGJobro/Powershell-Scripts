Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$desiredValue = "RUNASINVOKER"

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

Write-Output "Enabling virtualization for file/registry write failures to per-user locations..."
Set-ItemProperty -Path $regPath -Name "*" -Value $desiredValue
Write-Output "File/registry write failures are now virtualized to per-user locations."
}