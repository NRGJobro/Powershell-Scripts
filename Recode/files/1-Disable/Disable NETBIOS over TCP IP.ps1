Start-Job -ScriptBlock {
    Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True" | ForEach-Object {
    $_.SetTcpipNetbios(2)
    }
}