Start-Job -ScriptBlock {
    # Find and stop Nmap process if it is running
    if (Get-Process -Name "nmap" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "nmap" -Force
        Write-Output "Nmap process stopped."
    } else {
        Write-Output "Nmap process not found."
    }
    
    # Find and remove Nmap executable if it exists
    $nmapPaths = Get-ChildItem -Path "C:\" -Filter "nmap.exe" -Recurse -ErrorAction SilentlyContinue
    if ($nmapPaths) {
        $nmapPaths | Remove-Item -Force
        Write-Output "Nmap backdoor removed."
    } else {
        Write-Output "No Nmap backdoor found."
    }
}