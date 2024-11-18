Start-Job -ScriptBlock {
	Write-Output "Turning off Controlled Folder Access in Windows Defender..."
	try {
	    # Set Controlled Folder Access to Disabled
	    Set-MpPreference -EnableControlledFolderAccess Disabled -ErrorAction Stop
	    Write-Output "Controlled Folder Access has been turned off."
	} catch {
	    Write-Output "Failed to turn off Controlled Folder Access: $($_.Exception.Message)"
	}
	Write-Output "Controlled Folder Access configuration completed."
}