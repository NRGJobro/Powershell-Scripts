Start-Job -ScriptBlock {
    # Find and stop Python3 process if it is running
    if (Get-Process -Name "python" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "python" -Force
        Write-Output "Python3 process stopped."
    } else {
        Write-Output "Python3 process not found."
    }
    
    # Find and remove Python3 executable if it exists
    $pythonPaths = Get-ChildItem -Path "C:\" -Filter "python.exe" -Recurse -ErrorAction SilentlyContinue
    if ($pythonPaths) {
        $pythonPaths | Remove-Item -Force
        Write-Output "Python3 backdoor removed."
    } else {
        Write-Output "No Python3 backdoor found."
    }
}