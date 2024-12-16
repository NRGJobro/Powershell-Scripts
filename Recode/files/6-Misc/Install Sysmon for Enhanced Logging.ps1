Start-Job -ScriptBlock {
    Write-Output "Installing Sysmon for enhanced logging..."
    try {
        # Define the path to Sysmon executable
        $sysmonPath = "C:\Sysmon\Sysmon.exe"
        $configPath = "C:\Sysmon\sysmonconfig.xml"

        if (Test-Path $sysmonPath) {
            # Install Sysmon with a configuration file
            Start-Process -FilePath $sysmonPath -ArgumentList "-accepteula -i $configPath" -Wait -ErrorAction Stop
            Write-Output "Sysmon installed successfully with configuration."
        } else {
            Write-Output "Sysmon executable not found at path: $sysmonPath"
        }
    } catch {
        Write-Output "Failed to install Sysmon: $($_.Exception.Message)"
    }
    Write-Output "Sysmon installation process completed."
}