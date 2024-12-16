Start-Job -ScriptBlock {
    Get-NetAdapter | ForEach-Object {
        Disable-NetAdapterBinding -Name $_.Name -ComponentID "ms_tcpip6"  # Disable IPv6
        Disable-NetAdapterBinding -Name $_.Name -ComponentID "ms_pacer"   # Disable QoS Packet Scheduler
    }
}