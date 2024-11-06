# ----------------------------------------------------
# Enable gay shit at the end so it dosent interfere
# ----------------------------------------------------

Write-Output "Configuring Windows Defender Advanced Threat Protection (ATP)..."
try {
    # Enable Windows Defender ATP with PowerShell
    Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction Stop
    Write-Output "Controlled folder access enabled."
        
    # Enable cloud-delivered protection and automatic sample submission
    Set-MpPreference -MAPSReporting Advanced -SubmitSamplesConsent SendSafeSamples -ErrorAction Stop
    Write-Output "Cloud-delivered protection and automatic sample submission enabled."
        
    # Turn on real-time protection
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
    Write-Output "Real-time protection enabled."
} catch {
    Write-Output "Failed to configure Windows Defender ATP: $($_.Exception.Message)"
}
Write-Output "Windows Defender ATP configuration completed."