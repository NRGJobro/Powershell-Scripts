Start-Job -ScriptBlock { #Untested
# Ensure SSH ignores Rhosts configuration (PowerShell version)
$sshConfigPath = "C:\ProgramData\ssh\sshd_config"

if (Test-Path $sshConfigPath) {
    (Get-Content $sshConfigPath) -replace '^#?IgnoreRhosts.*', 'IgnoreRhosts yes' | Set-Content $sshConfigPath
    Write-Output "SSH is now configured to ignore Rhosts."
} else {
    Write-Output "SSH configuration file not found."
}
}