Start-Job -ScriptBlock {
    # Find and stop Burp Suite Community Edition process if it is running
    if (Get-Process -Name "burpsuite" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "burpsuite" -Force
        Write-Output "Burp Suite Community Edition process stopped."
    } else {
        Write-Output "Burp Suite Community Edition process not found."
    }
    
    # Find and remove Burp Suite Community Edition executable if it exists
    $burpPaths = Get-ChildItem -Path "C:\" -Filter "burpsuite*.exe" -Recurse -ErrorAction SilentlyContinue
    if ($burpPaths) {
        $burpPaths | Remove-Item -Force
        Write-Output "Burp Suite Community Edition removed."
    } else {
        Write-Output "No Burp Suite Community Edition found."
    }
}