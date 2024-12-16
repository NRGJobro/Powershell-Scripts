Start-Job -ScriptBlock { #Untested
# Deny SSH access for user 'Chell'
$sshConfigPath = "C:\ProgramData\ssh\sshd_config"

if (Test-Path $sshConfigPath) {
    (Get-Content $sshConfigPath) -replace '^#?DenyUsers.*', 'DenyUsers Chell' | Set-Content $sshConfigPath
    Write-Output "SSH access for user 'Chell' has been denied."
} else {
    Write-Output "SSH configuration file not found."
}
}