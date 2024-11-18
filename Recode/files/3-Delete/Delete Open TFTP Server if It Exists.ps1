Start-Job -ScriptBlock {
    $folderPath = "C:\Program Files\OpenTFTPServer"
    $processName = "OpenTFTPServerMT"  # Adjust this to match the name of the running process

    # Stop any running process that might be using the folder
    $runningProcesses = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($runningProcesses) {
        Write-Host "Stopping processes associated with: $processName..."
        Stop-Process -Name $processName -Force
        Write-Host "Processes stopped successfully."
    } else {
        Write-Host "No running processes found for: $processName"
    }

    # Check if the folder exists and attempt to remove it
    if (Test-Path $folderPath) {
        try {
            Write-Host "Removing folder: $folderPath..."
            Remove-Item -Path $folderPath -Recurse -Force
            Write-Host "Folder removed successfully."
        } catch {
            Write-Host "Failed to remove folder. Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Folder does not exist: $folderPath"
    }
}