Start-Job -ScriptBlock {
$wiresharkName = "Wireshark"

# Check if Wireshark is running
$wiresharkProcess = Get-Process -Name "wireshark" -ErrorAction SilentlyContinue

if ($wiresharkProcess) {
    Write-Output "Stopping Wireshark process..."
    Stop-Process -Name "wireshark" -Force
    Write-Output "Wireshark process has been stopped."
}

# Attempt to uninstall Wireshark using the uninstall executable directly from its install location
$possiblePaths = @(
    "$env:ProgramFiles\Wireshark",
    "$env:ProgramFiles(x86)\Wireshark"
)

foreach ($path in $possiblePaths) {
    if (Test-Path -Path "$path\uninstall.exe") {
        Write-Output "Found Wireshark uninstall executable. Uninstalling..."
        Start-Process -FilePath "$path\uninstall.exe" -ArgumentList "/S" -NoNewWindow -Wait
        Write-Output "Wireshark has been uninstalled successfully."
        break
    }
}

if (-not (Get-Process -Name "wireshark" -ErrorAction SilentlyContinue)) {
    Write-Output "Wireshark is not installed or has been successfully removed."
} else {
    Write-Output "Wireshark could not be uninstalled or was not found."
}
}