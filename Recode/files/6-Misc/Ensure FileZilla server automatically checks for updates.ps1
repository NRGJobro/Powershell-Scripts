Start-Job -ScriptBlock { #Untested
# Ensure FileZilla server automatically checks for updates
$configPath = "$env:APPDATA\FileZilla\filezilla.xml"

if (Test-Path $configPath) {
    [xml]$config = Get-Content -Path $configPath
    $updateNode = $config.DocumentElement.SelectSingleNode("//Settings/AutoUpdateCheck")

    if ($updateNode -eq $null) {
        Write-Output "Update check configuration not found. Adding automatic update check setting..."
        $settingsNode = $config.DocumentElement.SelectSingleNode("//Settings")
        $updateNode = $config.CreateElement("AutoUpdateCheck")
        $updateNode.InnerText = "1"
        $settingsNode.AppendChild($updateNode) | Out-Null
    } else {
        Write-Output "Setting FileZilla server to automatically check for updates..."
        $updateNode.InnerText = "1"
    }

    $config.Save($configPath)
    Write-Output "FileZilla server is now configured to automatically check for updates."
} else {
    Write-Output "FileZilla configuration file not found."
}
}