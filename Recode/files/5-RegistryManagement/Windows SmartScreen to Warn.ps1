Start-Job -ScriptBlock {
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
$registryValueName = "SmartScreenEnabled"

try {
    # Set value to "Prompt" for Warn or "Block" for blocking apps from being executed
    $value = "Prompt"  # or use "Block" for stricter enforcement

    Set-ItemProperty -Path $registryPath -Name $registryValueName -Value $value
    Write-Host "Windows SmartScreen configured to $value."
} catch {
    Write-Host "Failed to configure Windows SmartScreen. Error: $($_.Exception.Message)"
}
}