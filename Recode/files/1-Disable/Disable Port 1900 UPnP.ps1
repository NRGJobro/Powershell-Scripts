Start-Job -ScriptBlock {
    netsh advfirewall firewall add rule name="Block UPnP Port 1900" protocol=UDP dir=in localport=1900 action=block
}