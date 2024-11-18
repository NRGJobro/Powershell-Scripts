Start-Job -ScriptBlock {
    # Find and stop Netcat process if it is running
    if (Get-Process -Name "nc" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "nc" -Force
        Write-Output "Netcat process stopped."
    } else {
        Write-Output "Netcat process not found."
    }
    
    # Find and remove Netcat executable if it exists
    $netcatPaths = Get-ChildItem -Path "C:\" -Filter "nc.exe" -Recurse -ErrorAction SilentlyContinue
    if ($netcatPaths) {
        $netcatPaths | Remove-Item -Force
        Write-Output "Netcat backdoor removed."
    } else {
        Write-Output "No Netcat backdoor found."
    }
}