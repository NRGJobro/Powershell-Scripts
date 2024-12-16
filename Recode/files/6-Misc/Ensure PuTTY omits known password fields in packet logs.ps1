Start-Job -ScriptBlock { #Untested
# Ensure PuTTY omits known password fields in packet logs
$puttyConfigPath = "C:\Users\$env:USERNAME\AppData\Roaming\PuTTY\sessions"

if (Test-Path $puttyConfigPath) {
    Get-ChildItem -Path $puttyConfigPath -Filter "*.reg" | ForEach-Object {
        (Get-Content $_.FullName) -replace '^#?LogKnownPasswordFields=.*', 'LogKnownPasswordFields=no' | Set-Content $_.FullName
        Write-Output "PuTTY session configuration updated to omit known password fields in packet logs."
    }
} else {
    Write-Output "PuTTY session configuration folder not found."
}
}