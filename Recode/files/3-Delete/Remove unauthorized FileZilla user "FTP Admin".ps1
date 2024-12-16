Start-Job -ScriptBlock { #Untested
# Remove unauthorized FileZilla user "FTP Admin"
$configPath = "$env:APPDATA\FileZilla\filezilla.xml"

if (Test-Path $configPath) {
    [xml]$config = Get-Content -Path $configPath
    $userNodes = $config.DocumentElement.SelectNodes("//User[UserName='FTP Admin']")

    foreach ($userNode in $userNodes) {
        Write-Output "Removing unauthorized user 'FTP Admin'..."
        $userNode.ParentNode.RemoveChild($userNode) | Out-Null
    }

    $config.Save($configPath)
    Write-Output "Unauthorized user 'FTP Admin' has been removed."
} else {
    Write-Output "FileZilla configuration file not found."
}
}