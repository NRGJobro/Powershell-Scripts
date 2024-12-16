Start-Job -ScriptBlock {
    # Import Update Session COM Object
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()

    # Search for Available Updates
    Write-Output "Searching for updates..."
    $searchResult = $updateSearcher.Search("IsInstalled=0")

    if ($searchResult.Updates.Count -eq 0) {
        Write-Output "No new updates available."
    } else {
        Write-Output "Updates found: $($searchResult.Updates.Count)"
        
        # Create a collection to hold updates to be installed
        $updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
        foreach ($update in $searchResult.Updates) {
            $updatesToInstall.Add($update)
            Write-Output "Added update: $($update.Title)"
        }

        # Download and Install Updates
        $installer = $updateSession.CreateUpdateInstaller()
        $installer.Updates = $updatesToInstall
        
        Write-Output "Starting update installation in the background..."
        $installer.Install()
        Write-Output "Updates installation completed."
    }
}