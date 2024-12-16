Start-Job -ScriptBlock {
    Write-Output "Adjusting permissions for sensitive directories..."
    $directories = @(
        "C:\Windows\System32",
        "C:\Program Files",
        "C:\Program Files (x86)"
    )
    foreach ($dir in $directories) {
        try {
            # Set ownership to administrators
            takeown /f $dir /a
            # Grant full control to administrators and SYSTEM (directory level only)
            icacls $dir /grant "Administrators:F" /c
            icacls $dir /grant "SYSTEM:F" /c
            Write-Output "Permissions adjusted for $dir."
        } catch {
           # Write-Output "Failed to adjust permissions for $dir: $($Error[0].Exception.Message)"
        }
    }
    Write-Output "Permissions for sensitive directories adjusted."
}