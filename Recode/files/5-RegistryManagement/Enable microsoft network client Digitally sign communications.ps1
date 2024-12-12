Start-Job -ScriptBlock {
    # Always enable Microsoft Network Client to digitally sign communications

    # Modify registry to enforce digital signing of communications
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "RequireSecuritySignature" -Value 1
    Write-Output "Microsoft Network Client digital signing of communications enabled."

    # Verify the settings
    $signingStatus = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "RequireSecuritySignature"
    if ($signingStatus.RequireSecuritySignature -eq 1) {
        Write-Output "Digital signing is successfully enforced."
    } else {
        Write-Output "Failed to enforce digital signing."
    }
}