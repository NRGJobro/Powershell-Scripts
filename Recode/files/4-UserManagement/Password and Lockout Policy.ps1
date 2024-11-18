Start-Job -ScriptBlock {
    # Enforce password history: 24
    secedit.exe /export /cfg $env:TEMP\secpol.cfg
    (Get-Content -Path "$env:TEMP\secpol.cfg") -replace '(PasswordHistorySize = ).*', '$1 24' | Set-Content -Path "$env:TEMP\secpol.cfg"
    secedit.exe /configure /db secedit.sdb /cfg $env:TEMP\secpol.cfg

    # Maximum password age: 30 days
    net accounts /maxpwage:30

    # Minimum password age: 7 days
    net accounts /minpwage:7

    # Minimum password length: 12 characters
    net accounts /minpwlen:12

    # Account lockout duration: 30 minutes
    net accounts /lockoutduration:30

    # Account lockout threshold: 5 attempts
    net accounts /lockoutthreshold:5

    # Reset account lockout counter after: 30 minutes
    net accounts /lockoutwindow:30

    # Password complexity requirements: Enabled
    secedit.exe /export /cfg $env:TEMP\secpol.cfg
    (Get-Content -Path "$env:TEMP\secpol.cfg") -replace '(PasswordComplexity = ).*', '$1 1' | Set-Content -Path "$env:TEMP\secpol.cfg"
    secedit.exe /configure /db secedit.sdb /cfg $env:TEMP\secpol.cfg

    # Store passwords using reversible encryption: Disabled
    (Get-Content -Path "$env:TEMP\secpol.cfg") -replace '(ClearTextPassword = ).*', '$1 0' | Set-Content -Path "$env:TEMP\secpol.cfg"
    secedit.exe /configure /db secedit.sdb /cfg $env:TEMP\secpol.cfg
} 