Start-Job -ScriptBlock {
$profile = "Public"
$ruleName = "BlockInboundNotMatchingRule"
$desiredAction = "Block"

Write-Output "Configuring firewall to block incoming connections not matching a rule in the $profile profile..."
Set-NetFirewallProfile -Profile $profile -DefaultInboundAction $desiredAction
Write-Output "Incoming connections not matching a rule are now blocked in the $profile profile."
}