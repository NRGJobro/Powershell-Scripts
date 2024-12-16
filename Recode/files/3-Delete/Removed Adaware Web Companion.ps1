Start-Job -ScriptBlock {
# Check if the application is running and close it if necessary
$processName = "WebCompanion"
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($process) {
    Write-Output "Web Companion is running. Attempting to close it..."
    Stop-Process -Name $processName -Force
    Start-Sleep -Seconds 3
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($process) {
        Write-Output "Failed to close Web Companion process. Please ensure no other program is using it and try again."
        exit 1
    }
    Write-Output "Web Companion process stopped."
} else {
    Write-Output "Web Companion process is not running."
}

# Delete the Web Companion executable
$webCompanionExePath = "C:\Program Files (x86)\Lavasoft\Web Companion\Application\WebCompanion.exe"
if (Test-Path -Path $webCompanionExePath) {
    try {
        Write-Output "Attempting to delete Web Companion executable..."
        Remove-Item -Path $webCompanionExePath -Force -ErrorAction Stop
        Write-Output "Web Companion executable successfully deleted."
    } catch {
        Write-Output "Failed to delete Web Companion executable. Please check permissions or try running PowerShell as an administrator."
    }
} else {
    Write-Output "Web Companion executable not found. It may have already been removed."
}
}