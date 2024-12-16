Start-Job -ScriptBlock {
    Write-Output "Configuring Windows Defender Firewall with specific rules..."
    try {
        # Allow inbound RDP
        New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -ErrorAction Stop
        Write-Output "Firewall rule to allow RDP created."

        # Block inbound SMB traffic
        New-NetFirewallRule -DisplayName "Block SMB" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Block -ErrorAction Stop
        Write-Output "Firewall rule to block SMB created."

        # Allow outbound HTTP/HTTPS traffic
        New-NetFirewallRule -DisplayName "Allow HTTP/HTTPS Outbound" -Direction Outbound -Protocol TCP -LocalPort 80,443 -Action Allow -ErrorAction Stop
        Write-Output "Firewall rule to allow HTTP/HTTPS outbound traffic created."
    } catch {
        Write-Output "Failed to configure Windows Defender Firewall rules: $($_.Exception.Message)"
    }
    Write-Output "Windows Defender Firewall configuration completed."
}