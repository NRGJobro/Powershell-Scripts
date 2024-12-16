Start-Job -ScriptBlock {
    Disable-WindowsOptionalFeature -Online -FeatureName "TelnetClient" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "SNMP" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "RIP Listener" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "NFS" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "IIS" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart
}