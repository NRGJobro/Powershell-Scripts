Start-Job -ScriptBlock {
# Ensure FileZilla Server is allowed through the firewall
$ruleName = "FileZilla-Server-In-TCP"
$firewallRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

if ($firewallRule -eq $null) {
    Write-Output "Firewall rule for FileZilla Server not found. Creating rule to allow FileZilla Server through the firewall..."
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalPort 21 -Action Allow
    Write-Output "Firewall rule to allow FileZilla Server through the firewall has been created."
} elseif ($firewallRule.Enabled -eq 'False') {
    Write-Output "Firewall rule for FileZilla Server is disabled. Enabling rule..."
    Enable-NetFirewallRule -DisplayName $ruleName
    Write-Output "Firewall rule to allow FileZilla Server through the firewall has been enabled."
} else {
    Write-Output "Firewall rule to allow FileZilla Server through the firewall is already active."
}
}