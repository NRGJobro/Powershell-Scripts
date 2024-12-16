Start-Job -ScriptBlock {
    Write-Output "Restricting global object creation for all users..."
    try {
        # Update security policy to restrict global object creation
        secedit.exe /export /cfg $env:TEMP\secpol.cfg
        (Get-Content -Path "$env:TEMP\secpol.cfg") -replace '(SeCreateGlobalPrivilege = ).*', '${1}*S-1-5-32-544' | Set-Content -Path "$env:TEMP\secpol.cfg"
        secedit.exe /configure /db secedit.sdb /cfg $env:TEMP\secpol.cfg
        Write-Output "Global object creation restricted for all users."
    } catch {
        Write-Output "Failed to restrict global object creation: $($_.Exception.Message)"
    }
    Write-Output "Global object creation restriction completed."
}
