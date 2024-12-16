Start-Job -ScriptBlock {
    Write-Output "Implementing Software Restriction Policies (SRP)..."
    try {
        # Path for SRP GPO
        $srpPath = "HKLM:\Software\Policies\Microsoft\Windows\Safer\CodeIdentifiers"
        if (-not (Test-Path $srpPath)) {
            New-Item -Path $srpPath -Force | Out-Null
        }
        
        # Set default level to disallowed
        Set-ItemProperty -Path $srpPath -Name "DefaultLevel" -Value 0x00026200
        Write-Output "Default SRP level set to disallowed."

        # Create path rules to allow certain directories
        $allowedPaths = @(
            "C:\Program Files",
            "C:\Windows"
        )
        $ruleIndex = 0
        foreach ($path in $allowedPaths) {
            $rulePath = "$srpPath\Paths\$ruleIndex"
            if (-not (Test-Path $rulePath)) {
                New-Item -Path $rulePath -Force | Out-Null
            }
            Set-ItemProperty -Path $rulePath -Name "ItemData" -Value $path
            Set-ItemProperty -Path $rulePath -Name "SaferFlags" -Value 0x00000000
            Set-ItemProperty -Path $rulePath -Name "Description" -Value "Allow $path"
            Write-Output "SRP path rule added for: $path"
            $ruleIndex++
        }
    } catch {
        Write-Output "Failed to implement SRP: $($_.Exception.Message)"
    }
    Write-Output "Software Restriction Policies (SRP) implementation completed."
}