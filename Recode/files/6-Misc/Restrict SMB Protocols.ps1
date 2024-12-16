Start-Job -ScriptBlock {
    Write-Output "Restricting SMB protocols..."
    try {
        # Disable SMBv1
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction Stop
        Write-Output "SMBv1 protocol disabled."
        
        # Ensure SMBv2 and SMBv3 are enabled
        Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -ErrorAction Stop
        Write-Output "SMBv2 and SMBv3 protocols enabled."
    } catch {
        Write-Output "Failed to restrict SMB protocols: $($_.Exception.Message)"
    }
    Write-Output "SMB protocols restriction completed."
}