Start-Job -ScriptBlock {
    Get-NetAdapter | Set-DnsClient -RegisterThisConnectionsAddress $false
}