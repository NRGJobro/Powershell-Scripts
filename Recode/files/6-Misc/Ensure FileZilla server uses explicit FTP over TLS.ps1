Start-Job -ScriptBlock { #Untested
# Ensure FileZilla server uses explicit FTP over TLS
$configPath = "$env:APPDATA\FileZilla\filezilla.xml"

if (Test-Path $configPath) {
    [xml]$config = Get-Content -Path $configPath
    $tlsNode = $config.DocumentElement.SelectSingleNode("//Settings/ExplicitFTPOverTLS")

    if ($tlsNode -eq $null) {
        Write-Output "TLS configuration not found. Adding Explicit FTP over TLS setting..."
        $settingsNode = $config.DocumentElement.SelectSingleNode("//Settings")
        $tlsNode = $config.CreateElement("ExplicitFTPOverTLS")
        $tlsNode.InnerText = "1"
        $settingsNode.AppendChild($tlsNode) | Out-Null
    } else {
        Write-Output "Setting FileZilla server to use explicit FTP over TLS..."
        $tlsNode.InnerText = "1"
    }

    $config.Save($configPath)
    Write-Output "FileZilla server is now configured to use explicit FTP over TLS."
} else {
    Write-Output "FileZilla configuration file not found."
}
}