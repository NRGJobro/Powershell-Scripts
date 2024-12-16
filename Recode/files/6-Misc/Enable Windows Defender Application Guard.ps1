Start-Job -ScriptBlock {
    Write-Output "Enabling Windows Defender Application Guard..."
    try {
        # Enable Windows Defender Application Guard feature
        Enable-WindowsOptionalFeature -Online -FeatureName Windows-Defender-ApplicationGuard -NoRestart -ErrorAction Stop
        Write-Output "Windows Defender Application Guard enabled."
    } catch {
        Write-Output "Failed to enable Windows Defender Application Guard: $($_.Exception.Message)"
    }
    Write-Output "Windows Defender Application Guard configuration completed."
}