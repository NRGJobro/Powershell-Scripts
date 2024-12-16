Start-Job -ScriptBlock {
# Remove reverse shell backdoor if detected
$backdoorPath = "C:\Windows\System32\revshell.exe"

if (Test-Path $backdoorPath) {
    Write-Output "Removing reverse shell backdoor..."
    Remove-Item -Path $backdoorPath -Force
    Write-Output "Reverse shell backdoor has been removed."
} else {
    Write-Output "No reverse shell backdoor found."
}
}