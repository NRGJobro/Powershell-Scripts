Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$regName = "NoAutoUpdate"
$desiredValue = 0

# Check if the registry path exists, create it if it doesn't
if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

# Check the current value of the 'NoAutoUpdate' registry key
$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

# If the value doesn't exist, assume updates are disabled
if ($null -eq $currentValue) {
    Write-Output "'NoAutoUpdate' registry key not found. Assuming updates are disabled."
    $currentValue = 1 # Default to disabled if the value doesn't exist
}

# Enable Windows Automatic Updates by setting NoAutoUpdate to 0
if ($currentValue -ne $desiredValue) {
    Write-Output "Enabling Windows Automatic Updates..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Windows Automatic Updates are now enabled."
} else {
    Write-Output "Windows Automatic Updates are already enabled."
}

# Optionally, ensure that the AUOptions setting is correctly configured (for example, to automatically download and install updates)
$auOptionsPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$auOptionsName = "AUOptions"
$desiredAUOptionsValue = 4  # This sets updates to automatically download and install

if (-not (Test-Path $auOptionsPath)) {
    Write-Output "Creating registry path: $auOptionsPath"
    New-Item -Path $auOptionsPath -Force | Out-Null
}

$currentAUOptions = Get-ItemProperty -Path $auOptionsPath -Name $auOptionsName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $auOptionsName -ErrorAction SilentlyContinue

# Set AUOptions if it's not configured correctly
if ($currentAUOptions -ne $desiredAUOptionsValue) {
    Write-Output "Setting AUOptions to $desiredAUOptionsValue (Automatic download and installation)..."
    Set-ItemProperty -Path $auOptionsPath -Name $auOptionsName -Value $desiredAUOptionsValue
    Write-Output "AUOptions set to $desiredAUOptionsValue. Automatic Updates will now be downloaded and installed automatically."
} else {
    Write-Output "AUOptions are already set correctly."
}

# Trigger Windows Update Service to refresh settings
Write-Output "Refreshing Windows Update service..."
Start-Service -Name "wuauserv"

Write-Output "Windows Automatic Updates are now fully enabled and configured."
}