# Prompt User to Clean Up and Restart
$cleanupResponse = Read-Host "Do you want to clean up temporary files and restart the system? (y/n)"
if ($cleanupResponse -eq "y") {
    Start-Job -ScriptBlock {
        Write-Output "Cleaning up temporary files..."
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Output "Temporary files cleaned up."
        Write-Output "Restarting the system..."
        Restart-Computer -Force
    }
} else {
    Write-Output "Cleanup and restart skipped."
}