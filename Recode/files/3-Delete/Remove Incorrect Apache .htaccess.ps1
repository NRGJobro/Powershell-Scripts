Start-Job -ScriptBlock {
    Write-Output "Removing incorrect Apache .htaccess files..."
    $htaccessPaths = Get-ChildItem -Path "C:\" -Filter ".htaccess" -Recurse -ErrorAction SilentlyContinue
    foreach ($file in $htaccessPaths) {
        try {
            Remove-Item -Path $file.FullName -Force
            Write-Output "Removed incorrect .htaccess file: $($file.FullName)"
        } catch {
            Write-Output "Failed to remove .htaccess file: $($file.FullName) - $($_.Exception.Message)"
        }
    }
    Write-Output "Apache .htaccess file removal process completed."
}