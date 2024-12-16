Start-Job -ScriptBlock {
    Disable-NetFirewallRule -DisplayName "*Edge*"
    Disable-NetFirewallRule -DisplayName "*Search*"
    Disable-NetFirewallRule -DisplayName "*Photos*"
    Disable-NetFirewallRule -DisplayName "*Xbox*"
    Disable-NetFirewallRule -DisplayName "*MSN*"
}