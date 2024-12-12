Start-Job -ScriptBlock {
    # Find and stop Jellyfin Media Player process if it is running
    if (Get-Process -Name "jellyfin" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "jellyfin" -Force
        Write-Output "Jellyfin Media Player process stopped."
    } else {
        Write-Output "Jellyfin Media Player process not found."
    }
    
    # Find and remove Jellyfin Media Player executable if it exists
    $jellyfinPaths = Get-ChildItem -Path "C:\" -Filter "jellyfin*.exe" -Recurse -ErrorAction SilentlyContinue
    if ($jellyfinPaths) {
        $jellyfinPaths | Remove-Item -Force
        Write-Output "Jellyfin Media Player removed."
    } else {
        Write-Output "No Jellyfin Media Player found."
    }
}