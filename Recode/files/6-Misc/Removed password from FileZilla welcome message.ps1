Start-Job -ScriptBlock {
# Remove password from FileZilla welcome message configuration
$configPath = "$env:APPDATA\FileZilla\filezilla.xml"

if (Test-Path $configPath) {
    [xml]$config = Get-Content -Path $configPath
    $welcomeMessage = $config.Settings.WelcomeMessage

    if ($welcomeMessage -ne $null) {
        $welcomeMessage.InnerText = $welcomeMessage.InnerText -replace '(?i)password:\s*\S+', 'password: [removed]'
        $config.Save($configPath)
        Write-Output "Password has been removed from the FileZilla welcome message."
    } else {
        Write-Output "No welcome message found in FileZilla configuration."
    }
} else {
    Write-Output "FileZilla configuration file not found."
}
}