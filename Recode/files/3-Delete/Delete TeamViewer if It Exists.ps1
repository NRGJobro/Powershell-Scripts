Start-Job -ScriptBlock {
    Write-Host "Checking for TeamViewer process..."
    $teamViewerProcess = Get-Process -Name "TeamViewer" -ErrorAction SilentlyContinue
    if ($teamViewerProcess) {
        Write-Host "Stopping TeamViewer process..."
        Stop-Process -Name "TeamViewer" -Force
        Write-Host "TeamViewer process stopped."
    }
    
    Write-Host "Checking for TeamViewer installation..."
    $teamViewerUninstallPath = "C:\Program Files\TeamViewer\uninstall.exe"
    if (Test-Path $teamViewerUninstallPath) {
        Write-Host "Uninstalling TeamViewer..."
        Start-Process -FilePath $teamViewerUninstallPath -ArgumentList "/S" -Wait
        Write-Host "TeamViewer uninstalled."
    } else {
        Write-Host "TeamViewer is not installed."
    }
}