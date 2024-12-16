Start-Job -ScriptBlock { #Untested
# Ensure PuTTY uses SSH protocol 2
$puttyConfigPath = "C:\Users\$env:USERNAME\AppData\Roaming\PuTTY\sessions"

if (Test-Path $puttyConfigPath) {
    Get-ChildItem -Path $puttyConfigPath -Filter "*.reg" | ForEach-Object {
        (Get-Content $_.FullName) -replace '^#?Protocol=.*', 'Protocol=2' | Set-Content $_.FullName
        Write-Output "PuTTY session configuration updated to use SSH protocol 2."
    }
} else {
    Write-Output "PuTTY session configuration folder not found."
}
}