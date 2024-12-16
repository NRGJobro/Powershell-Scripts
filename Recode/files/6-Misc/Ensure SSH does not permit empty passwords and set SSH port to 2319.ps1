Start-Job -ScriptBlock { #Untested
# Ensure SSH does not permit empty passwords and set SSH port to 2319
$sshConfigPath = "C:\ProgramData\ssh\sshd_config"

if (Test-Path $sshConfigPath) {
    (Get-Content $sshConfigPath) -replace '^#?PermitEmptyPasswords.*', 'PermitEmptyPasswords no' |
    Set-Content $sshConfigPath
    (Get-Content $sshConfigPath) -replace '^#?Port.*', 'Port 2319' | Set-Content $sshConfigPath
    Write-Output "SSH is now configured to not permit empty passwords and use port 2319."
} else {
    Write-Output "SSH configuration file not found."
}
}