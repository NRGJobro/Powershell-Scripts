Start-Job -ScriptBlock {
    # Update Google Chrome automatically

    # Ensure Google Chrome is closed before updating
    if (Get-Process -Name "chrome" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "chrome" -Force
        Write-Output "Google Chrome process stopped."
    } else {
        Write-Output "Google Chrome was not running."
    }

    # Define the path to Chrome's installer/updater
    $chromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
    $downloadPath = "$env:TEMP\chrome_installer.exe"

    # Download the latest Chrome installer
    Invoke-WebRequest -Uri $chromeInstallerUrl -OutFile $downloadPath -ErrorAction Stop
    Write-Output "Chrome installer downloaded."

    # Run the installer silently to update Chrome
    Start-Process -FilePath $downloadPath -ArgumentList "/silent /install" -NoNewWindow -Wait
    Write-Output "Google Chrome updated successfully."

    # Clean up the installer
    Remove-Item -Path $downloadPath -Force
    Write-Output "Installer file removed."
}
