Start-Job -ScriptBlock {
# Ensure SSH is allowed through the firewall
$ruleName = "OpenSSH-Server-In-TCP"
$firewallRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

if ($firewallRule -eq $null) {
    Write-Output "Firewall rule for SSH not found. Creating rule to allow SSH through the firewall..."
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
    Write-Output "Firewall rule to allow SSH through the firewall has been created."
} elseif ($firewallRule.Enabled -eq 'False') {
    Write-Output "Firewall rule for SSH is disabled. Enabling rule..."
    Enable-NetFirewallRule -DisplayName $ruleName
    Write-Output "Firewall rule to allow SSH through the firewall has been enabled."
} else {
    Write-Output "Firewall rule to allow SSH through the firewall is already active."
}
}