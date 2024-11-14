# ----------------------------------------------------
# Ask if on server
# ----------------------------------------------------

$serverQuestionResponse = Read-Host "Are you on Windows Server? (y/n)"

# ----------------------------------------------------
# Turn off shit i need to turn off for bypass yay
# ----------------------------------------------------

Write-Output "Turning off Controlled Folder Access in Windows Defender..."
try {
    # Set Controlled Folder Access to Disabled
    Set-MpPreference -EnableControlledFolderAccess Disabled -ErrorAction Stop
    Write-Output "Controlled Folder Access has been turned off."
} catch {
    Write-Output "Failed to turn off Controlled Folder Access: $($_.Exception.Message)"
}
Write-Output "Controlled Folder Access configuration completed."

# ----------------------------------------------------
# Command 13: Remove Netcat Backdoor if It Exists
# ----------------------------------------------------

Start-Job -ScriptBlock {
    # Find and stop Netcat process if it is running
    if (Get-Process -Name "nc" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "nc" -Force
        Write-Output "Netcat process stopped."
    } else {
        Write-Output "Netcat process not found."
    }
    
    # Find and remove Netcat executable if it exists
    $netcatPaths = Get-ChildItem -Path "C:\" -Filter "nc.exe" -Recurse -ErrorAction SilentlyContinue
    if ($netcatPaths) {
        $netcatPaths | Remove-Item -Force
        Write-Output "Netcat backdoor removed."
    } else {
        Write-Output "No Netcat backdoor found."
    }
}

# ----------------------------------------------------
# Command 10: Remove Prohibited MP3 Files if They Exist
# ----------------------------------------------------

Start-Job -ScriptBlock {
    $mp3Files = Get-ChildItem -Path "C:\" -Filter "*.mp3" -Recurse -ErrorAction SilentlyContinue
    if ($mp3Files) {
        $mp3Files | Remove-Item -Force
        Write-Output "Prohibited MP3 files removed."
    } else {
        Write-Output "No prohibited MP3 files found."
    }
}

# ----------------------------------------------------
# Command 1: Start Windows Updates (Run in Background)
# ----------------------------------------------------

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

# ----------------------------------------------------
# Command 2: Password and Lockout Policies via Local Security Policy
# ----------------------------------------------------

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

# ----------------------------------------------------
# Command 3: Enable Audit for Credential Validation Success
# ----------------------------------------------------

Start-Job -ScriptBlock {
    auditpol /set /subcategory:"Credential Validation" /success:enable
}

# ----------------------------------------------------
# Command 4: Configure UAC to Prompt on Secure Desktop
# ----------------------------------------------------

Start-Job -ScriptBlock {
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 2 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
}

# ----------------------------------------------------
# Command 5: Ensure Windows Defender Firewall is Running
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Set-Service -Name "MpsSvc" -StartupType Automatic
    Start-Service -Name "MpsSvc"
}

# ----------------------------------------------------
# Command 6: Disable AutoPlay for All Drives
# ----------------------------------------------------

Start-Job -ScriptBlock {
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 255 /f
}

# ----------------------------------------------------
# Command 7: Configure Windows SmartScreen to Warn
# ----------------------------------------------------

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

# ----------------------------------------------------
# Command 8: Stop and Disable FTP Service if it Exists
# ----------------------------------------------------

Start-Job -ScriptBlock {
    if (Get-Service -Name "FTPSVC" -ErrorAction SilentlyContinue) {
        Stop-Service -Name "FTPSVC" -Force
        Set-Service -Name "FTPSVC" -StartupType Disabled
        Write-Output "FTP service stopped and disabled."
    } else {
        Write-Output "FTP service not found."
    }
}

# ----------------------------------------------------
# Command 9: Stop and Disable WWW Publishing Service if it Exists
# ----------------------------------------------------

Start-Job -ScriptBlock {
    if (Get-Service -Name "W3SVC" -ErrorAction SilentlyContinue) {
        Stop-Service -Name "W3SVC" -Force
        Set-Service -Name "W3SVC" -StartupType Disabled
        Write-Output "WWW Publishing service stopped and disabled."
    } else {
        Write-Output "WWW Publishing service not found."
    }
}



# ----------------------------------------------------
# Command 11: Close and Uninstall TeamViewer if It Exists
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Host "Checking for TeamViewer process..."
    $teamViewerProcess = Get-Process -Name "TeamViewer" -ErrorAction SilentlyContinue
    if ($teamViewerProcess) {
        Write-Host "Stopping TeamViewer process..."
        Stop-Process -Name "TeamViewer" -Force
        Write-Host "TeamViewer process stopped."
    }
    
    Write-Host "Checking for TeamViewer installation..."
    $teamViewerUninstallPath = "C:\Program Files\TeamViewer\uninstall.exe"
    if (Test-Path $teamViewerUninstallPath) {
        Write-Host "Uninstalling TeamViewer..."
        Start-Process -FilePath $teamViewerUninstallPath -ArgumentList "/S" -Wait
        Write-Host "TeamViewer uninstalled."
    } else {
        Write-Host "TeamViewer is not installed."
    }
}

# ----------------------------------------------------
# Command 12: Close and Uninstall Open TFTP Server if It Exists
# ----------------------------------------------------

Start-Job -ScriptBlock {
    $folderPath = "C:\Program Files\OpenTFTPServer"
    $processName = "OpenTFTPServerMT"  # Adjust this to match the name of the running process

    # Stop any running process that might be using the folder
    $runningProcesses = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($runningProcesses) {
        Write-Host "Stopping processes associated with: $processName..."
        Stop-Process -Name $processName -Force
        Write-Host "Processes stopped successfully."
    } else {
        Write-Host "No running processes found for: $processName"
    }

    # Check if the folder exists and attempt to remove it
    if (Test-Path $folderPath) {
        try {
            Write-Host "Removing folder: $folderPath..."
            Remove-Item -Path $folderPath -Recurse -Force
            Write-Host "Folder removed successfully."
        } catch {
            Write-Host "Failed to remove folder. Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Folder does not exist: $folderPath"
    }
}




# ----------------------------------------------------
# Command 14: Enable RDP Network Level Authentication
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Enabling RDP Network Level Authentication..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1
    Write-Output "RDP Network Level Authentication enabled."
}

# ----------------------------------------------------
# Command 15: Set RDP Security Layer to SSL
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Setting RDP Security Layer to SSL..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer" -Value 2
    Write-Output "RDP Security Layer set to SSL."
}

# ----------------------------------------------------
# Command 16: Configure Firewall Settings to Default Settings
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Configuring Windows Firewall settings to default..."
    netsh advfirewall reset
    Write-Output "Windows Firewall settings have been reset to default."
}

# ----------------------------------------------------
# Command 17: Adjust Permissions of Sensitive Directories
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Adjusting permissions for sensitive directories..."
    $directories = @(
        "C:\Windows\System32",
        "C:\Program Files",
        "C:\Program Files (x86)"
    )
    foreach ($dir in $directories) {
        try {
            # Set ownership to administrators
            takeown /f $dir /a
            # Grant full control to administrators and SYSTEM (directory level only)
            icacls $dir /grant "Administrators:F" /c
            icacls $dir /grant "SYSTEM:F" /c
            Write-Output "Permissions adjusted for $dir."
        } catch {
           # Write-Output "Failed to adjust permissions for $dir: $($Error[0].Exception.Message)"
        }
    }
    Write-Output "Permissions for sensitive directories adjusted."
}

# ----------------------------------------------------
# Command 18: Update Tripwire
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Updating Tripwire..."
    # Assuming Tripwire is installed and the path to the update script or command is known
    $tripwirePath = "C:\Program Files\Tripwire\twadmin"
    if (Test-Path $tripwirePath) {
        Start-Process -FilePath "$tripwirePath\twadmin.exe" -ArgumentList "--update-polfile" -Wait
        Write-Output "Tripwire update completed."
    } else {
        Write-Output "Tripwire installation not found."
    }
}

# ----------------------------------------------------
# Command 19: Remove Incorrect Apache .htaccess
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Removing incorrect Apache .htaccess files..."
    $htaccessPaths = Get-ChildItem -Path "C:\" -Filter ".htaccess" -Recurse -ErrorAction SilentlyContinue
    foreach ($file in $htaccessPaths) {
        try {
            Remove-Item -Path $file.FullName -Force
            Write-Output "Removed incorrect .htaccess file: $($file.FullName)"
        } catch {
            Write-Output "Failed to remove .htaccess file: $($file.FullName) - $($_.Exception.Message)"
        }
    }
    Write-Output "Apache .htaccess file removal process completed."
}

# ----------------------------------------------------
# Command 20: Enable Firefox Pop-up Blocker
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Enabling Firefox pop-up blocker..."
    $firefoxPrefsPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    $profiles = Get-ChildItem -Path $firefoxPrefsPath -Directory -ErrorAction SilentlyContinue
    foreach ($profile in $profiles) {
        $prefsFile = "$($profile.FullName)\prefs.js"
        if (Test-Path $prefsFile) {
            try {
                # Add or update the preference to enable the pop-up blocker
                (Get-Content -Path $prefsFile) -replace '(user_pref\("dom.disable_open_during_load", )false', '${1}true' | Set-Content -Path $prefsFile
                Write-Output "Pop-up blocker enabled for profile: $($profile.FullName)"
            } catch {
                Write-Output "Failed to enable pop-up blocker for profile: $($profile.FullName) - $($_.Exception.Message)"
            }
        }
    }
    Write-Output "Firefox pop-up blocker enabled."
}

# ----------------------------------------------------
# Command 21: Disable Unnecessary Services
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Disabling unnecessary services..."
    $servicesToDisable = @(
        "RemoteRegistry",
        "Telnet",
        "SNMP",
        "Fax",
        "wuauserv"  # Windows Update Service (if not required)
    )
    foreach ($service in $servicesToDisable) {
        try {
            Set-Service -Name $service -StartupType Disabled -ErrorAction Stop
            Stop-Service -Name $service -Force -ErrorAction Stop
            Write-Output "Service '$service' has been disabled and stopped."
        } catch {
            Write-Output "Failed to disable service '$service': $($_.Exception.Message)"
        }
    }
    Write-Output "Unnecessary services have been disabled."
}

# ----------------------------------------------------
# Command 22: Enable BitLocker Encryption for System and Data Drives
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Enabling BitLocker encryption for system and data drives..."
    $drives = Get-BitLockerVolume | Where-Object { $_.VolumeType -in ('OperatingSystem', 'FixedData') }
    foreach ($drive in $drives) {
        try {
            if ($drive.ProtectionStatus -eq 'Off') {
                Enable-BitLocker -MountPoint $drive.MountPoint -EncryptionMethod XtsAes256 -UsedSpaceOnly -TpmProtector -ErrorAction Stop
                Write-Output "BitLocker encryption enabled for drive: $($drive.MountPoint)"
            } else {
                Write-Output "BitLocker is already enabled for drive: $($drive.MountPoint)"
            }
        } catch {
            Write-Output "Failed to enable BitLocker for drive $($drive.MountPoint): $($_.Exception.Message)"
        }
    }
    Write-Output "BitLocker encryption process completed."
}

# ----------------------------------------------------
# Command 23: Implement Software Restriction Policies (SRP)
# ----------------------------------------------------

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

# ----------------------------------------------------
# Command 24: Restrict SMB Protocols
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Restricting SMB protocols..."
    try {
        # Disable SMBv1
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction Stop
        Write-Output "SMBv1 protocol disabled."
        
        # Ensure SMBv2 and SMBv3 are enabled
        Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -ErrorAction Stop
        Write-Output "SMBv2 and SMBv3 protocols enabled."
    } catch {
        Write-Output "Failed to restrict SMB protocols: $($_.Exception.Message)"
    }
    Write-Output "SMB protocols restriction completed."
}

# ----------------------------------------------------
# Command 25: Disable Windows Remote Management (WinRM) if Not Needed
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Disabling Windows Remote Management (WinRM) if not needed..."
    try {
        # Disable WinRM service
        Set-Service -Name "WinRM" -StartupType Disabled -ErrorAction Stop
        Stop-Service -Name "WinRM" -Force -ErrorAction Stop
        Write-Output "Windows Remote Management (WinRM) service disabled."
    } catch {
        Write-Output "Failed to disable WinRM service: $($_.Exception.Message)"
    }
    Write-Output "WinRM service configuration completed."
}

# ----------------------------------------------------
# Command 26: Configure Windows Defender Firewall with Specific Rules
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Configuring Windows Defender Firewall with specific rules..."
    try {
        # Allow inbound RDP
        New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -ErrorAction Stop
        Write-Output "Firewall rule to allow RDP created."

        # Block inbound SMB traffic
        New-NetFirewallRule -DisplayName "Block SMB" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Block -ErrorAction Stop
        Write-Output "Firewall rule to block SMB created."

        # Allow outbound HTTP/HTTPS traffic
        New-NetFirewallRule -DisplayName "Allow HTTP/HTTPS Outbound" -Direction Outbound -Protocol TCP -LocalPort 80,443 -Action Allow -ErrorAction Stop
        Write-Output "Firewall rule to allow HTTP/HTTPS outbound traffic created."
    } catch {
        Write-Output "Failed to configure Windows Defender Firewall rules: $($_.Exception.Message)"
    }
    Write-Output "Windows Defender Firewall configuration completed."
}

# ----------------------------------------------------
# Command 27: Enable Windows Defender Application Guard
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Enabling Windows Defender Application Guard..."
    try {
        # Enable Windows Defender Application Guard feature
        Enable-WindowsOptionalFeature -Online -FeatureName Windows-Defender-ApplicationGuard -NoRestart -ErrorAction Stop
        Write-Output "Windows Defender Application Guard enabled."
    } catch {
        Write-Output "Failed to enable Windows Defender Application Guard: $($_.Exception.Message)"
    }
    Write-Output "Windows Defender Application Guard configuration completed."
}

# ----------------------------------------------------
# Command 28: Install Sysmon for Enhanced Logging
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Installing Sysmon for enhanced logging..."
    try {
        # Define the path to Sysmon executable
        $sysmonPath = "C:\Sysmon\Sysmon.exe"
        $configPath = "C:\Sysmon\sysmonconfig.xml"

        if (Test-Path $sysmonPath) {
            # Install Sysmon with a configuration file
            Start-Process -FilePath $sysmonPath -ArgumentList "-accepteula -i $configPath" -Wait -ErrorAction Stop
            Write-Output "Sysmon installed successfully with configuration."
        } else {
            Write-Output "Sysmon executable not found at path: $sysmonPath"
        }
    } catch {
        Write-Output "Failed to install Sysmon: $($_.Exception.Message)"
    }
    Write-Output "Sysmon installation process completed."
}

# ----------------------------------------------------
# Command 29: Restrict Global Object Creation for All Users
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Write-Output "Restricting global object creation for all users..."
    try {
        # Update security policy to restrict global object creation
        secedit.exe /export /cfg $env:TEMP\secpol.cfg
        (Get-Content -Path "$env:TEMP\secpol.cfg") -replace '(SeCreateGlobalPrivilege = ).*', '${1}*S-1-5-32-544' | Set-Content -Path "$env:TEMP\secpol.cfg"
        secedit.exe /configure /db secedit.sdb /cfg $env:TEMP\secpol.cfg
        Write-Output "Global object creation restricted for all users."
    } catch {
        Write-Output "Failed to restrict global object creation: $($_.Exception.Message)"
    }
    Write-Output "Global object creation restriction completed."
}

# ----------------------------------------------------
# Command 30: Disable Wi-Fi Sense Settings
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Value 0
}

# ----------------------------------------------------
# Command 31: Disable Unnecessary Network Services (IPv6, QoS)
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Get-NetAdapter | ForEach-Object {
        Disable-NetAdapterBinding -Name $_.Name -ComponentID "ms_tcpip6"  # Disable IPv6
        Disable-NetAdapterBinding -Name $_.Name -ComponentID "ms_pacer"   # Disable QoS Packet Scheduler
    }
}

# ----------------------------------------------------
# Command 32: Uncheck "Register This Connection's Address in DNS"
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Get-NetAdapter | Set-DnsClient -RegisterThisConnectionsAddress $false
}

# ----------------------------------------------------
# Command 33: Disable NETBIOS over TCP/IP
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True" | ForEach-Object {
    $_.SetTcpipNetbios(2)
    }
}

# ----------------------------------------------------
# Command 34: Disable Port 1900 UPnP
# ----------------------------------------------------

Start-Job -ScriptBlock {
    netsh advfirewall firewall add rule name="Block UPnP Port 1900" protocol=UDP dir=in localport=1900 action=block
}

# ----------------------------------------------------
# Command 35: Stop and Disable UPnP Device Host Service
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Set-Service -Name "upnphost" -StartupType Disabled
    Stop-Service -Name "upnphost" -Force
}

# ----------------------------------------------------
# Command 36: Stop and Disable SNMP Trap Service
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Set-Service -Name "SNMPTRAP" -StartupType Disabled
    Stop-Service -Name "SNMPTRAP" -Force
}

# ----------------------------------------------------
# Command 37: Never Enable Telnet, SNMP, RIP Listener, NFS, IIS, SMB v1
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Disable-WindowsOptionalFeature -Online -FeatureName "TelnetClient" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "SNMP" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "RIP Listener" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "NFS" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "IIS" -NoRestart
    Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart
}

# ----------------------------------------------------
# Command 38: Restrict Shared Folders to ADMIN$, C$, IPC$
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Get-SmbShare | Where-Object { $_.Name -notin @("ADMIN$", "C$", "IPC$") } | Remove-SmbShare -Force
}

# ----------------------------------------------------
# Command 39: Disable Inbound Firewall Rules for MS Edge, Search, Photos, Xbox, etc.
# ----------------------------------------------------

Start-Job -ScriptBlock {
    Disable-NetFirewallRule -DisplayName "*Edge*"
    Disable-NetFirewallRule -DisplayName "*Search*"
    Disable-NetFirewallRule -DisplayName "*Photos*"
    Disable-NetFirewallRule -DisplayName "*Xbox*"
    Disable-NetFirewallRule -DisplayName "*MSN*"
}

# ----------------------------------------------------
# Command 40: Enable Auditing for Both Success and Failure
# ----------------------------------------------------

Start-Job -ScriptBlock {
   Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" | foreach-object {
        auditpol /set /subcategory:* /success:enable /failure:enable
   }
}

# ----------------------------------------------------
# Command 41: Remove Internet Explorer if it's installed
# ----------------------------------------------------

Start-Job -ScriptBlock {
$ieProcess = Get-Process -Name "iexplore" -ErrorAction SilentlyContinue

if ($ieProcess) {
    Write-Output "Internet Explorer is running. Stopping process..."
    Stop-Process -Name "iexplore" -Force
    Write-Output "Internet Explorer process has been stopped."
}

# Remove Internet Explorer if it's installed
$features = Get-WindowsOptionalFeature -Online | Where-Object {$_.FeatureName -eq "Internet-Explorer-Optional-amd64"}

if ($features.State -eq "Enabled") {
    Write-Output "Internet Explorer is installed. Removing..."
    Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart
    Write-Output "Internet Explorer has been removed."
} elseif ($features.State -eq "Disabled") {
    Write-Output "Internet Explorer is already removed."
} else {
    Write-Output "Internet Explorer is not found on this system."
}
}

# ----------------------------------------------------
# Command 43: Configure LAN Manager to only send NTLMv2 responses
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$regName = "LmCompatibilityLevel"
$desiredValue = 5

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Setting LAN Manager to only send NTLMv2 responses..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "LAN Manager is now configured to only send NTLMv2 responses."
} else {
    Write-Output "LAN Manager is already configured to only send NTLMv2 responses."
}
}

# ----------------------------------------------------
# Command 44: Prohibit NULL session fallback
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$regName = "RestrictAnonymous"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Prohibiting NULL session fallback..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "NULL session fallback is now prohibited."
} else {
    Write-Output "NULL session fallback is already prohibited."
}

}

# ----------------------------------------------------
# Command 45: Configure system to not display the last logged-in user
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regName = "DontDisplayLastUserName"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring system to not display the last logged-in user..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "System is now configured to not display the last logged-in user."
} else {
    Write-Output "System is already configured to not display the last logged-in user."
}

}

# ----------------------------------------------------
# Command 46: Users cannot add or logon with Microsoft accounts
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regName = "NoConnectedUser"
$desiredValue = 3

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring system to prevent users from adding or logging on with Microsoft accounts..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "System is now configured to prevent users from adding or logging on with Microsoft accounts."
} else {
    Write-Output "System is already configured to prevent users from adding or logging on with Microsoft accounts."
}

}

# ----------------------------------------------------
# Command 47: Users cannot add or logon with Microsoft accounts
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regName = "NoConnectedUser"
$desiredValue = 3

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring system to prevent users from adding or logging on with Microsoft accounts..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "System is now configured to prevent users from adding or logging on with Microsoft accounts."
} else {
    Write-Output "System is already configured to prevent users from adding or logging on with Microsoft accounts."
}

}

# ----------------------------------------------------
# Command 48: Nobody can access Credential Manager as a trusted caller
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regName = "DisableCredMgrAccess"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring system to prevent access to Credential Manager as a trusted caller..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "System is now configured to prevent access to Credential Manager as a trusted caller."
} else {
    Write-Output "System is already configured to prevent access to Credential Manager as a trusted caller."
}

}

# ----------------------------------------------------
# Command 49: Core dumps are disabled on system crash
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl"
$regName = "CrashDumpEnabled"
$desiredValue = 0

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Disabling core dumps on system crash..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Core dumps are now disabled on system crash."
} else {
    Write-Output "Core dumps are already disabled on system crash."
}

}

# ----------------------------------------------------
# Command 50: Windows Defender no longer runs in passive mode
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$regName = "ForceDefenderPassiveMode"
$desiredValue = 0

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Disabling passive mode for Windows Defender..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Windows Defender is no longer running in passive mode."
} else {
    Write-Output "Windows Defender is already configured to not run in passive mode."
}

}

# ----------------------------------------------------
# Command 51: Only administrators can install printer drivers
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\Software\Policies\Microsoft\Windows NT\Printers"
$regName = "RestrictDriverInstallationToAdministrators"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Restricting printer driver installation to administrators only..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Printer driver installation is now restricted to administrators only."
} else {
    Write-Output "Printer driver installation is already restricted to administrators only."
}

}

# ----------------------------------------------------
# Command 52: The system requires approval from an administrator before running unknown software (Defender Smartscreen)
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\System"
$regName = "EnableSmartScreen"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Enabling Defender SmartScreen to require administrator approval for unknown software..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Defender SmartScreen is now enabled to require administrator approval for unknown software."
} else {
    Write-Output "Defender SmartScreen is already configured to require administrator approval for unknown software."
}
}

# ----------------------------------------------------
# Command 53: Require approval from an administrator before running unknown software (Defender SmartScreen) and prevent bypass
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\System"
$regNameSmartScreen = "EnableSmartScreen"
$regNameBypass = "ConfigureAppInstallControl"
$desiredValueSmartScreen = 1
$desiredValueBypass = 2

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

# Enable SmartScreen
$currentValueSmartScreen = Get-ItemProperty -Path $regPath -Name $regNameSmartScreen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regNameSmartScreen -ErrorAction SilentlyContinue
if ($currentValueSmartScreen -ne $desiredValueSmartScreen) {
    Write-Output "Enabling Defender SmartScreen to require administrator approval for unknown software..."
    Set-ItemProperty -Path $regPath -Name $regNameSmartScreen -Value $desiredValueSmartScreen
    Write-Output "Defender SmartScreen is now enabled to require administrator approval for unknown software."
} else {
    Write-Output "Defender SmartScreen is already configured to require administrator approval for unknown software."
}

# Prevent bypassing SmartScreen
$currentValueBypass = Get-ItemProperty -Path $regPath -Name $regNameBypass -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regNameBypass -ErrorAction SilentlyContinue
if ($currentValueBypass -ne $desiredValueBypass) {
    Write-Output "Configuring Defender SmartScreen to prevent bypassing attempts for unknown software..."
    Set-ItemProperty -Path $regPath -Name $regNameBypass -Value $desiredValueBypass
    Write-Output "Defender SmartScreen is now configured to prevent bypassing attempts for unknown software."
} else {
    Write-Output "Defender SmartScreen is already configured to prevent bypassing attempts for unknown software."
}
}

# ----------------------------------------------------
# Command 54: File/registry write failures are virtualized to per-user locations
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$desiredValue = "RUNASINVOKER"

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

Write-Output "Enabling virtualization for file/registry write failures to per-user locations..."
Set-ItemProperty -Path $regPath -Name "*" -Value $desiredValue
Write-Output "File/registry write failures are now virtualized to per-user locations."
}

# ----------------------------------------------------
# Command 55: App notifications do not show on the lock screen
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
$regName = "NoToastApplicationNotificationOnLockScreen"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Disabling app notifications on the lock screen..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "App notifications are now disabled on the lock screen."
} else {
    Write-Output "App notifications are already disabled on the lock screen."
}
}

# ----------------------------------------------------
# Command 56: Incoming connections not matching a rule are blocked in Public profile
# ----------------------------------------------------

Start-Job -ScriptBlock {
$profile = "Public"
$ruleName = "BlockInboundNotMatchingRule"
$desiredAction = "Block"

Write-Output "Configuring firewall to block incoming connections not matching a rule in the $profile profile..."
Set-NetFirewallProfile -Profile $profile -DefaultInboundAction $desiredAction
Write-Output "Incoming connections not matching a rule are now blocked in the $profile profile."
}

# ----------------------------------------------------
# Command 57: Windows Automatic Updates are enabled
# ----------------------------------------------------

Start-Job -ScriptBlock {
# ----------------------------------------------------
# Command 57: Ensure Windows Automatic Updates are enabled
# ----------------------------------------------------

$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$regName = "NoAutoUpdate"
$desiredValue = 0

# Check if the registry path exists, create it if it doesn't
if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

# Check the current value of the 'NoAutoUpdate' registry key
$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

# If the value doesn't exist, assume updates are disabled
if ($null -eq $currentValue) {
    Write-Output "'NoAutoUpdate' registry key not found. Assuming updates are disabled."
    $currentValue = 1 # Default to disabled if the value doesn't exist
}

# Enable Windows Automatic Updates by setting NoAutoUpdate to 0
if ($currentValue -ne $desiredValue) {
    Write-Output "Enabling Windows Automatic Updates..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Windows Automatic Updates are now enabled."
} else {
    Write-Output "Windows Automatic Updates are already enabled."
}

# Optionally, ensure that the AUOptions setting is correctly configured (for example, to automatically download and install updates)
$auOptionsPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$auOptionsName = "AUOptions"
$desiredAUOptionsValue = 4  # This sets updates to automatically download and install

if (-not (Test-Path $auOptionsPath)) {
    Write-Output "Creating registry path: $auOptionsPath"
    New-Item -Path $auOptionsPath -Force | Out-Null
}

$currentAUOptions = Get-ItemProperty -Path $auOptionsPath -Name $auOptionsName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $auOptionsName -ErrorAction SilentlyContinue

# Set AUOptions if it's not configured correctly
if ($currentAUOptions -ne $desiredAUOptionsValue) {
    Write-Output "Setting AUOptions to $desiredAUOptionsValue (Automatic download and installation)..."
    Set-ItemProperty -Path $auOptionsPath -Name $auOptionsName -Value $desiredAUOptionsValue
    Write-Output "AUOptions set to $desiredAUOptionsValue. Automatic Updates will now be downloaded and installed automatically."
} else {
    Write-Output "AUOptions are already set correctly."
}

# Trigger Windows Update Service to refresh settings
Write-Output "Refreshing Windows Update service..."
Start-Service -Name "wuauserv"

Write-Output "Windows Automatic Updates are now fully enabled and configured."
}

# ----------------------------------------------------
# Command 58: Malicious AMSI provider removed
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Microsoft\AMSI\Providers"

if (Test-Path $regPath) {
    $providers = Get-ChildItem -Path $regPath
    foreach ($provider in $providers) {
        Write-Output "Removing malicious AMSI provider: $($provider.Name)"
        Remove-Item -Path $provider.PSPath -Recurse -Force
    }
    Write-Output "All detected AMSI providers have been removed."
} else {
    Write-Output "No AMSI providers found to remove."
}
}

# ----------------------------------------------------
# Command 59: Remove the malicious program HideUL if detected
# ----------------------------------------------------

Start-Job -ScriptBlock {
$hideULPath = "C:\Program Files\HideUL"

if (Test-Path $hideULPath) {
    Write-Output "Removing malicious program HideUL..."
    Remove-Item -Path $hideULPath -Recurse -Force
    Write-Output "Malicious program HideUL has been removed."
} else {
    Write-Output "HideUL program not found."
}
}

# ----------------------------------------------------
# Command 60: Remove the malicious system driver WinDivert if detected
# ----------------------------------------------------

Start-Job -ScriptBlock {
$winDivertPath = "C:\Windows\System32\drivers\WinDivert.sys"

if (Test-Path $winDivertPath) {
    Write-Output "Removing malicious system driver WinDivert..."
    Remove-Item -Path $winDivertPath -Force
    Write-Output "Malicious system driver WinDivert has been removed."
} else {
    Write-Output "WinDivert driver not found."
}
}

# ----------------------------------------------------
# Command 61: Ensure Notepad++ is up to date if installed
# ----------------------------------------------------

Start-Job -ScriptBlock {
$notepadPlusPlusPath = "C:\Program Files\Notepad++\notepad++.exe"

if (Test-Path $notepadPlusPlusPath) {
    Write-Output "Checking for Notepad++ updates..."
    Start-Process -FilePath $notepadPlusPlusPath -ArgumentList "-updatecheck" -NoNewWindow -Wait
    Write-Output "Notepad++ update check complete."
} else {
    Write-Output "Notepad++ is not installed."
}
}

# ----------------------------------------------------
# Command 62: Prohibit user access to the Store application
# ----------------------------------------------------

Start-Job -ScriptBlock {
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
$regName = "RemoveWindowsStore"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Prohibiting user access to the Store application..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "User access to the Store application is now prohibited."
} else {
    Write-Output "User access to the Store application is already prohibited."
}
}

# ----------------------------------------------------
# Command 63: Check if UEFI Secure Boot is enabled
# ----------------------------------------------------
Start-Job -ScriptBlock { #Manually do UEIF in BIOS
# Check if UEFI Secure Boot is enabled
   $secureBoot = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue

   if ($secureBoot -eq $false) {
       Write-Output "UEFI Secure Boot is not enabled or not supported on this system. Please enable it manually in the BIOS/UEFI settings."
   } else {
       Write-Output "UEFI Secure Boot is enabled."
   }
}

# ----------------------------------------------------
# Command 64: Check if Windows Update services are running
# ----------------------------------------------------

Start-Job -ScriptBlock {
$serviceName = "wuauserv"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -and $service.Status -eq 'Running') {
    Write-Output "Windows Update service is running."
} else {
    Write-Output "Windows Update service is not running. Starting the service..."
    Start-Service -Name $serviceName
    Write-Output "Windows Update service has been started."
}
}

# ----------------------------------------------------
# Command 65: Check if Windows Event Log service is running
# ----------------------------------------------------

Start-Job -ScriptBlock {
$serviceName = "eventlog"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -and $service.Status -eq 'Running') {
    Write-Output "Windows Event Log service is running."
} elseif ($service -and $service.StartType -eq 'Disabled') {
    Write-Output "Windows Event Log service is disabled. Enabling the service..."
    Set-Service -Name $serviceName -StartupType Automatic
    Start-Service -Name $serviceName
    Write-Output "Windows Event Log service has been enabled and started."
} else {
    Write-Output "Windows Event Log service is not running. Starting the service..."
    Start-Service -Name $serviceName
    Write-Output "Windows Event Log service has been started."
}
}

# ----------------------------------------------------
# Command 66: Removed password from FileZilla welcome message
# ----------------------------------------------------

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

# ----------------------------------------------------
# Command 67: Configure RDP connections to require SSL
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Configure RDP connections to require SSL
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$regName = "SecurityLayer"
$desiredValue = 2

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring RDP connections to require SSL..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "RDP connections are now configured to require SSL."
} else {
    Write-Output "RDP connections are already configured to require SSL."
}
}

# ----------------------------------------------------
# Command 68: Deny local logon for Remote Desktop Users
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Deny local logon for Remote Desktop Users
$localPolicyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$denyLogonLocally = "SeDenyInteractiveLogonRight"
$group = "Remote Desktop Users"

# Get the current list of groups/users denied local logon
$currentValue = (Get-ItemProperty -Path $localPolicyPath -Name $denyLogonLocally -ErrorAction SilentlyContinue).$denyLogonLocally

if ($currentValue -notlike "*$group*") {
    Write-Output "Denying local logon for Remote Desktop Users..."
    $newValue = if ($currentValue) { "$currentValue,$group" } else { "$group" }
    Set-ItemProperty -Path $localPolicyPath -Name $denyLogonLocally -Value $newValue
    Write-Output "Remote Desktop Users are now denied local logon."
} else {
    Write-Output "Remote Desktop Users are already denied local logon."
}

}

# ----------------------------------------------------
# Command 69: Configure RDP to require a secure RPC connection
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Configure RDP to require a secure RPC connection
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$regName = "UserAuthentication"
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring RDP to require a secure RPC connection..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "RDP is now configured to require a secure RPC connection."
} else {
    Write-Output "RDP is already configured to require a secure RPC connection."
}
}

# ----------------------------------------------------
# Command 70: Remove SMB version 1 if it is installed
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Remove SMB version 1 if it is installed
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$regName = "SMB1"

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -eq 1) {
    Write-Output "SMB version 1 is enabled. Disabling..."
    Set-ItemProperty -Path $regPath -Name $regName -Value 0
    Write-Output "SMB version 1 has been disabled."
} else {
    Write-Output "SMB version 1 is already disabled or not installed."
}
}

# ----------------------------------------------------
# Command 71: Ensure SMB requires packet signing
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Ensure SMB requires packet signing
$regPathServer = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$regNameServer = "EnableSecuritySignature"
$desiredValueServer = 1

$regPathWorkstation = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$regNameWorkstation = "EnableSecuritySignature"
$desiredValueWorkstation = 1

# Configure SMB Server to require packet signing
$currentValueServer = Get-ItemProperty -Path $regPathServer -Name $regNameServer -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regNameServer -ErrorAction SilentlyContinue

if ($currentValueServer -ne $desiredValueServer) {
    Write-Output "Configuring SMB Server to require packet signing..."
    Set-ItemProperty -Path $regPathServer -Name $regNameServer -Value $desiredValueServer
    Write-Output "SMB Server is now configured to require packet signing."
} else {
    Write-Output "SMB Server is already configured to require packet signing."
}

# Configure SMB Workstation to require packet signing
$currentValueWorkstation = Get-ItemProperty -Path $regPathWorkstation -Name $regNameWorkstation -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regNameWorkstation -ErrorAction SilentlyContinue

if ($currentValueWorkstation -ne $desiredValueWorkstation) {
    Write-Output "Configuring SMB Workstation to require packet signing..."
    Set-ItemProperty -Path $regPathWorkstation -Name $regNameWorkstation -Value $desiredValueWorkstation
    Write-Output "SMB Workstation is now configured to require packet signing."
} else {
    Write-Output "SMB Workstation is already configured to require packet signing."
}
}

# ----------------------------------------------------
# Command 72: Ensure SMB does not send plaintext passwords
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Ensure SMB does not send plaintext passwords
$regPathWorkstation = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$regNamePlaintextPassword = "EnablePlainTextPassword"
$desiredValue = 0

$currentValue = Get-ItemProperty -Path $regPathWorkstation -Name $regNamePlaintextPassword -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regNamePlaintextPassword -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring SMB to not send plaintext passwords..."
    Set-ItemProperty -Path $regPathWorkstation -Name $regNamePlaintextPassword -Value $desiredValue
    Write-Output "SMB is now configured to not send plaintext passwords."
} else {
    Write-Output "SMB is already configured to not send plaintext passwords."
}
}

# ----------------------------------------------------
# Command 73: Configure the system to use FIPS 140 compliant cryptographic algorithms
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Configure the system to use FIPS 140 compliant cryptographic algorithms
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$regName = "FIPSAlgorithmPolicy"
$desiredValue = 1

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Configuring the system to use FIPS 140 compliant cryptographic algorithms..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "The system is now configured to use FIPS 140 compliant cryptographic algorithms."
} else {
    Write-Output "The system is already configured to use FIPS 140 compliant cryptographic algorithms."
}
}

# ----------------------------------------------------
# Command 74:  Enable file and registry write failure virtualization to per-user locations
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Enable file and registry write failure virtualization to per-user locations
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$desiredValue = "RUNASINVOKER"

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

Write-Output "Enabling virtualization for file and registry write failures to per-user locations..."
Set-ItemProperty -Path $regPath -Name "*" -Value $desiredValue
Write-Output "File and registry write failures are now virtualized to per-user locations."
}

# ----------------------------------------------------
# Command 75: Removed hidden network shares
# ----------------------------------------------------

Start-Job -ScriptBlock {
$shares = Get-WmiObject -Query "SELECT * FROM Win32_Share" | Where-Object { $_.Name -like '*$' }

foreach ($share in $shares) {
    Write-Output "Removing hidden network share: $($share.Name)"
    Remove-WmiObject -Path $share.__PATH
}

Write-Output "All hidden network shares have been removed."
}

# ----------------------------------------------------
# Command 76: Grant full control over C:\ftp to a specified user group
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Grant full control over C:\ftp to a specified user group
$ftpFolderPath = "C:\ftp"
$ftpUsersGroup = "ftpusers"

# Create the folder if it does not exist
if (-not (Test-Path -Path $ftpFolderPath)) {
    Write-Output "Folder C:\ftp does not exist. Creating the folder..."
    New-Item -Path $ftpFolderPath -ItemType Directory | Out-Null
}

# Get the ACL for the folder and set permissions
$acl = Get-Acl -Path $ftpFolderPath
$ftpUsers = New-Object System.Security.Principal.NTAccount($ftpUsersGroup)
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($ftpUsers, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

$acl.SetAccessRule($accessRule)
Set-Acl -Path $ftpFolderPath -AclObject $acl

Write-Output "Full control over C:\ftp has been granted to $ftpUsersGroup."
}

# ----------------------------------------------------
# Command 77: Grant read-only privileges over C:\ftp\aperture-moon to Authenticated Users
# ----------------------------------------------------

Start-Job -ScriptBlock { #read-only aperture-moon
# Grant read-only privileges over C:\ftp\aperture-moon to Authenticated Users
$folderPath = "C:\ftp\aperture-moon"
$authUsersGroup = "Authenticated Users"

# Create the folder if it does not exist
if (-not (Test-Path -Path $folderPath)) {
    Write-Output "Folder C:\ftp\aperture-moon does not exist. Creating the folder..."
    New-Item -Path $folderPath -ItemType Directory | Out-Null
}

# Get the ACL for the folder and set permissions
$acl = Get-Acl -Path $folderPath
$authUsers = New-Object System.Security.Principal.NTAccount($authUsersGroup)
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($authUsers, "Read", "ContainerInherit,ObjectInherit", "None", "Allow")

$acl.SetAccessRule($accessRule)
Set-Acl -Path $folderPath -AclObject $acl

Write-Output "Read-only privileges over C:\ftp\aperture-moon have been granted to Authenticated Users."
}

# ----------------------------------------------------
# Command 78: Remove unauthorized FileZilla user "FTP Admin"
# ----------------------------------------------------

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

# ----------------------------------------------------
# Command 79: Ensure FileZilla server uses explicit FTP over TLS
# ----------------------------------------------------

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

# ----------------------------------------------------
# Command 80: Ensure FileZilla server automatically checks for updates
# ----------------------------------------------------

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

# ----------------------------------------------------
# Command 81: Ensure SSH ignores Rhosts configuration
# ----------------------------------------------------

Start-Job -ScriptBlock { #Untested
# Ensure SSH ignores Rhosts configuration (PowerShell version)
$sshConfigPath = "C:\ProgramData\ssh\sshd_config"

if (Test-Path $sshConfigPath) {
    (Get-Content $sshConfigPath) -replace '^#?IgnoreRhosts.*', 'IgnoreRhosts yes' | Set-Content $sshConfigPath
    Write-Output "SSH is now configured to ignore Rhosts."
} else {
    Write-Output "SSH configuration file not found."
}
}

# ----------------------------------------------------
# Command 82: Deny SSH access for user 'Chell'
# ----------------------------------------------------

Start-Job -ScriptBlock { #Untested
# Deny SSH access for user 'Chell'
$sshConfigPath = "C:\ProgramData\ssh\sshd_config"

if (Test-Path $sshConfigPath) {
    (Get-Content $sshConfigPath) -replace '^#?DenyUsers.*', 'DenyUsers Chell' | Set-Content $sshConfigPath
    Write-Output "SSH access for user 'Chell' has been denied."
} else {
    Write-Output "SSH configuration file not found."
}
}

# ----------------------------------------------------
# Command 83: Ensure SSH does not permit empty passwords
# ----------------------------------------------------

Start-Job -ScriptBlock { #Untested
# Ensure SSH does not permit empty passwords
$sshConfigPath = "C:\ProgramData\ssh\sshd_config"

if (Test-Path $sshConfigPath) {
    (Get-Content $sshConfigPath) -replace '^#?PermitEmptyPasswords.*', 'PermitEmptyPasswords no' | Set-Content $sshConfigPath
    Write-Output "SSH is now configured to not permit empty passwords."
} else {
    Write-Output "SSH configuration file not found."
}
}

# ----------------------------------------------------
# Command 84: Ensure SSH does not permit empty passwords and set SSH port to 2319
# ----------------------------------------------------

Start-Job -ScriptBlock { #Untested
# Ensure SSH does not permit empty passwords and set SSH port to 2319
$sshConfigPath = "C:\ProgramData\ssh\sshd_config"

if (Test-Path $sshConfigPath) {
    (Get-Content $sshConfigPath) -replace '^#?PermitEmptyPasswords.*', 'PermitEmptyPasswords no' |
    Set-Content $sshConfigPath
    (Get-Content $sshConfigPath) -replace '^#?Port.*', 'Port 2319' | Set-Content $sshConfigPath
    Write-Output "SSH is now configured to not permit empty passwords and use port 2319."
} else {
    Write-Output "SSH configuration file not found."
}
}

# ----------------------------------------------------
# Command 85: Ensure SSH does not permit empty passwords, set SSH port to 2319, and disable password authentication
# ----------------------------------------------------

Start-Job -ScriptBlock { #Untested
# Ensure SSH does not permit empty passwords, set SSH port to 2319, and disable password authentication
$sshConfigPath = "C:\ProgramData\ssh\sshd_config"

if (Test-Path $sshConfigPath) {
    (Get-Content $sshConfigPath) -replace '^#?PermitEmptyPasswords.*', 'PermitEmptyPasswords no' |
    Set-Content $sshConfigPath
    (Get-Content $sshConfigPath) -replace '^#?Port.*', 'Port 2319' | Set-Content $sshConfigPath
    (Get-Content $sshConfigPath) -replace '^#?PasswordAuthentication.*', 'PasswordAuthentication no' | Set-Content $sshConfigPath
    Write-Output "SSH is now configured to not permit empty passwords, use port 2319, and disable password authentication."
} else {
    Write-Output "SSH configuration file not found."
}
}

# ----------------------------------------------------
# Command 86: Ensure PuTTY uses SSH protocol 2
# ----------------------------------------------------

Start-Job -ScriptBlock { #Untested
# Ensure PuTTY uses SSH protocol 2
$puttyConfigPath = "C:\Users\$env:USERNAME\AppData\Roaming\PuTTY\sessions"

if (Test-Path $puttyConfigPath) {
    Get-ChildItem -Path $puttyConfigPath -Filter "*.reg" | ForEach-Object {
        (Get-Content $_.FullName) -replace '^#?Protocol=.*', 'Protocol=2' | Set-Content $_.FullName
        Write-Output "PuTTY session configuration updated to use SSH protocol 2."
    }
} else {
    Write-Output "PuTTY session configuration folder not found."
}
}

# ----------------------------------------------------
# Command 87: Ensure PuTTY omits known password fields in packet logs
# ----------------------------------------------------

Start-Job -ScriptBlock { #Untested
# Ensure PuTTY omits known password fields in packet logs
$puttyConfigPath = "C:\Users\$env:USERNAME\AppData\Roaming\PuTTY\sessions"

if (Test-Path $puttyConfigPath) {
    Get-ChildItem -Path $puttyConfigPath -Filter "*.reg" | ForEach-Object {
        (Get-Content $_.FullName) -replace '^#?LogKnownPasswordFields=.*', 'LogKnownPasswordFields=no' | Set-Content $_.FullName
        Write-Output "PuTTY session configuration updated to omit known password fields in packet logs."
    }
} else {
    Write-Output "PuTTY session configuration folder not found."
}
}

# ----------------------------------------------------
# Command 88: Ensure VLC notifies when updates are available
# ----------------------------------------------------

Start-Job -ScriptBlock { #Untested
# Ensure VLC notifies when updates are available
$vlcConfigPath = "$env:APPDATA\vlc\vlcrc"

if (Test-Path $vlcConfigPath) {
    (Get-Content $vlcConfigPath) -replace '^#?qt-updates-notif=.*', 'qt-updates-notif=1' | Set-Content $vlcConfigPath
    Write-Output "VLC configuration updated to notify when updates are available."
} else {
    Write-Output "VLC configuration file not found."
}
}

# ----------------------------------------------------
# Command 89: Ensure OpenSSH Server is active
# ----------------------------------------------------

Start-Job -ScriptBlock { #Kinda untested
# Ensure OpenSSH Server is active
$serviceName = "sshd"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -eq $null) {
    Write-Output "OpenSSH Server service not found. Please ensure OpenSSH Server is installed."
} elseif ($service.Status -eq 'Running') {
    Write-Output "OpenSSH Server is active and running."
} else {
    Write-Output "OpenSSH Server is not running. Starting the service..."
    Start-Service -Name $serviceName
    Write-Output "OpenSSH Server has been started."
}
}

# ----------------------------------------------------
# Command 90: Ensure FileZilla Server is active
# ----------------------------------------------------

Start-Job -ScriptBlock { #Untested
# Ensure FileZilla Server is active
$serviceName = "FileZilla Server"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -eq $null) {
    Write-Output "FileZilla Server service not found. Please ensure FileZilla Server is installed."
} elseif ($service.Status -eq 'Running') {
    Write-Output "FileZilla Server is active and running."
} else {
    Write-Output "FileZilla Server is not running. Starting the service..."
    Start-Service -Name $serviceName
    Write-Output "FileZilla Server has been started."
}
}

# ----------------------------------------------------
# Command 91: Ensure SSH is allowed through the firewall
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Ensure SSH is allowed through the firewall
$ruleName = "OpenSSH-Server-In-TCP"
$firewallRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

if ($firewallRule -eq $null) {
    Write-Output "Firewall rule for SSH not found. Creating rule to allow SSH through the firewall..."
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
    Write-Output "Firewall rule to allow SSH through the firewall has been created."
} elseif ($firewallRule.Enabled -eq 'False') {
    Write-Output "Firewall rule for SSH is disabled. Enabling rule..."
    Enable-NetFirewallRule -DisplayName $ruleName
    Write-Output "Firewall rule to allow SSH through the firewall has been enabled."
} else {
    Write-Output "Firewall rule to allow SSH through the firewall is already active."
}
}

# ----------------------------------------------------
# Command 92: Ensure FileZilla Server is allowed through the firewall
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Ensure FileZilla Server is allowed through the firewall
$ruleName = "FileZilla-Server-In-TCP"
$firewallRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

if ($firewallRule -eq $null) {
    Write-Output "Firewall rule for FileZilla Server not found. Creating rule to allow FileZilla Server through the firewall..."
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalPort 21 -Action Allow
    Write-Output "Firewall rule to allow FileZilla Server through the firewall has been created."
} elseif ($firewallRule.Enabled -eq 'False') {
    Write-Output "Firewall rule for FileZilla Server is disabled. Enabling rule..."
    Enable-NetFirewallRule -DisplayName $ruleName
    Write-Output "Firewall rule to allow FileZilla Server through the firewall has been enabled."
} else {
    Write-Output "Firewall rule to allow FileZilla Server through the firewall is already active."
}
}

# ----------------------------------------------------
# Command 93: Ensure UPnP is not enabled
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Ensure UPnP is not enabled
$regPath = "HKLM:\SOFTWARE\Microsoft\DirectPlayNATHelp\DPNHUPnP"
$regName = "UPnPMode"
$desiredValue = 0

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Disabling UPnP..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "UPnP has been disabled."
} else {
    Write-Output "UPnP is already disabled."
}
}

# ----------------------------------------------------
# Command 94: Automatically deny elevation prompts for standard users
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Automatically deny elevation prompts for standard users
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regName = "ConsentPromptBehaviorUser"
$desiredValue = 0

if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

if ($currentValue -ne $desiredValue) {
    Write-Output "Automatically denying elevation prompts for standard users..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Elevation prompts for standard users are now automatically denied."
} else {
    Write-Output "Elevation prompts for standard users are already automatically denied."
}
}

# ----------------------------------------------------
# Command 95: Remove reverse shell backdoor if detected
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Remove reverse shell backdoor if detected
$backdoorPath = "C:\Windows\System32\revshell.exe"

if (Test-Path $backdoorPath) {
    Write-Output "Removing reverse shell backdoor..."
    Remove-Item -Path $backdoorPath -Force
    Write-Output "Reverse shell backdoor has been removed."
} else {
    Write-Output "No reverse shell backdoor found."
}
}


# ----------------------------------------------------------------
# Update Firefox if it Needs Updating because yeah fuck that shit
# ----------------------------------------------------------------
Start-Job -ScriptBlock {
Write-Output "Checking for Firefox updates..."
try {
    # Close Firefox if it is running
    $firefoxProcess = Get-Process -Name "firefox" -ErrorAction SilentlyContinue
    if ($firefoxProcess) {
        Write-Output "Closing Firefox..."
        Stop-Process -Name "firefox" -Force -ErrorAction Stop
        Write-Output "Firefox has been closed."
    }

    # Uninstall Firefox if it is installed
    $uninstallPath = "C:\Program Files\Mozilla Firefox\uninstall\helper.exe"
    if (Test-Path $uninstallPath) {
        Write-Output "Uninstalling Firefox..."
        Start-Process -FilePath $uninstallPath -ArgumentList "/S" -Wait -ErrorAction Stop
        Write-Output "Firefox has been uninstalled."
    } else {
        Write-Output "Firefox uninstall helper not found, proceeding to update."
    }
    
    $firefoxInstallerUrl = "https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US"
    $installerPath = "$env:TEMP\FirefoxInstaller.exe"
    
    # Download the latest Firefox installer with timeout to prevent infinite hangs
    Write-Output "Downloading the latest Firefox installer..."
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($firefoxInstallerUrl, $installerPath)
    
    if (-Not (Test-Path $installerPath)) {
        throw "Firefox installer not found."
    }
    
    # Install/Update Firefox
    Write-Output "Installing/Updating Firefox..."
    Start-Process -FilePath $installerPath -ArgumentList "/s" -Wait -ErrorAction Stop
    Write-Output "Firefox has been updated successfully."
} catch {
    Write-Output "Failed to update Firefox: $($_.Exception.Message)"
}
Write-Output "Firefox update process completed."
}

# ----------------------------------------------------
# Firefox shit to do after firefox is updated
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Firefox popup blocker enabled
$firefoxPrefsPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
$profileDirs = Get-ChildItem -Path $firefoxPrefsPath -Directory -ErrorAction SilentlyContinue

if ($profileDirs) {
    foreach ($profile in $profileDirs) {
        $prefsFile = "$($profile.FullName)\prefs.js"
        if (Test-Path $prefsFile) {
            Write-Output "Enabling popup blocker for Firefox profile: $($profile.Name)"
            Add-Content -Path $prefsFile -Value 'user_pref("dom.disable_open_during_load", true);'
            Write-Output "Popup blocker enabled for Firefox profile: $($profile.Name)"
        } else {
            Write-Output "prefs.js not found in profile: $($profile.Name)"
        }
    }
} else {
    Write-Output "No Firefox profiles found."
}
}

Start-Job -ScriptBlock {
# Enable "Block dangerous and deceptive content" in Firefox
$firefoxPrefsPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
$profileDirs = Get-ChildItem -Path $firefoxPrefsPath -Directory -ErrorAction SilentlyContinue

if ($profileDirs) {
    foreach ($profile in $profileDirs) {
        $prefsFile = "$($profile.FullName)\prefs.js"
        if (Test-Path $prefsFile) {
            Write-Output "Enabling 'Block dangerous and deceptive content' for Firefox profile: $($profile.Name)"
            Add-Content -Path $prefsFile -Value 'user_pref("browser.safebrowsing.malware.enabled", true);'
            Add-Content -Path $prefsFile -Value 'user_pref("browser.safebrowsing.phishing.enabled", true);'
            Write-Output "'Block dangerous and deceptive content' enabled for Firefox profile: $($profile.Name)"
        } else {
            Write-Output "prefs.js not found in profile: $($profile.Name)"
        }
    }
} else {
    Write-Output "No Firefox profiles found."
}
}

Start-Job -ScriptBlock {
# Disable Firefox profiles and sync
$firefoxPrefsPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
$profileDirs = Get-ChildItem -Path $firefoxPrefsPath -Directory -ErrorAction SilentlyContinue

if ($profileDirs) {
    foreach ($profile in $profileDirs) {
        $prefsFile = "$($profile.FullName)\prefs.js"
        if (Test-Path $prefsFile) {
            Write-Output "Disabling profiles and sync for Firefox profile: $($profile.Name)"
            Add-Content -Path $prefsFile -Value 'user_pref("services.sync.enabled", false);'
            Write-Output "Profiles and sync disabled for Firefox profile: $($profile.Name)"
        } else {
            Write-Output "prefs.js not found in profile: $($profile.Name)"
        }
    }
} else {
    Write-Output "No Firefox profiles found."
}
}

#-----------------------------------------------------
# User Management Script
#-----------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Function Show-InputBox {
    param (
        [string]$title,
        [string]$prompt
    )
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $title
    $form.Width = 500
    $form.Height = 400
    $form.StartPosition = 'CenterScreen'

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $prompt
    $label.AutoSize = $true
    $label.Location = '10,20'
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Width = 460
    $textBox.Height = 250
    $textBox.Location = '10,50'
    $textBox.Multiline = $true
    $textBox.ScrollBars = 'Vertical'
    $form.Controls.Add($textBox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = 'OK'
    $okButton.Location = '200,320'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($okButton)

    $form.AcceptButton = $okButton

    if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $textBox.Text
    }
    return ''
}

# Function to get a Yes/No response
Function Get-YesNo($prompt) {
    do {
        $response = Read-Host "$prompt (Y/N)"
    } until ($response -match '^[YyNn]$')
    return $response.ToUpper()
}

# Function to automatically set a secure password for a user
Function Set-SecurePassword($username) {
    $Password = ConvertTo-SecureString -String "CyberPatri0t!?@" -AsPlainText -Force
    $user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
    if ($user) {
        try {
            $user | Set-LocalUser -Password $Password
        } catch {
            Write-Host "Failed to set password for user '$username'. Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "User '$username' does not exist. Cannot set password."
    }
}

# Function to remove unauthorized users
Function Remove-UnauthorizedUser($username) {
    try {
        Remove-LocalUser -Name $username -ErrorAction Stop
        Write-Host "User '$username' has been removed successfully."
    } catch {
        Write-Host "Failed to remove user '$username'. Error: $($_.Exception.Message)"
    }
}

# Function to parse authorized users and admins from input
Function Parse-AuthorizedUsers {
    param (
        [string]$inputText
    )
    
    $authorizedAdmins = @()
    $authorizedUsers = @()

    $lines = $inputText -split "`n"
    $section = ''

    foreach ($line in $lines) {
        $line = $line.Trim()
        if ($line -like 'Authorized Administrators:*') {
            $section = 'admins'
        } elseif ($line -like 'Authorized Users:*') {
            $section = 'users'
        } elseif ($line -ne '' -and $section -eq 'admins') {
            if ($line -like '*password:*') {
                continue
            }
            $authorizedAdmins += ($line -split '\s+')[0]
        } elseif ($line -ne '' -and $section -eq 'users') {
            $authorizedUsers += $line
        }
    }

    return [PSCustomObject]@{
        Admins = $authorizedAdmins
        Users = $authorizedUsers
    }
}

# Manage local user accounts if needed
$ManageUsers = Get-YesNo "Do you need to manage local user accounts?"

If ($ManageUsers -eq "Y") {
    # Manage local user accounts if needed
    $readmeInput = Show-InputBox -title 'Read Me Users' -prompt 'Paste the authorized users and admins from the readme file here'
    $parsedData = Parse-AuthorizedUsers -inputText $readmeInput

    $AuthorizedUsers = $parsedData.Users
    $AuthorizedAdmins = $parsedData.Admins

    Write-Host "Managing local user accounts..."

    # Get all local users excluding built-in accounts
    $LocalUsers = Get-LocalUser | Where-Object { $_.Name -ne "Administrator" -and $_.Name -ne "Guest" -and $_.Name -ne "DefaultAccount" -and $_.Name -ne "WDAGUtilityAccount" }

    # Set secure passwords for authorized users
    $AuthorizedUsers = $AuthorizedUsers | Sort-Object
    $LocalUsers = $LocalUsers | Sort-Object Name

    foreach ($User in $LocalUsers) {
        if ($User.Name -in $AuthorizedUsers -or $User.Name -in $AuthorizedAdmins) {
            Write-Host "User '$($User.Name)' is authorized. Setting a secure password..."
            Set-SecurePassword -username $User.Name
        } else {
            Write-Host "User '$($User.Name)' is not authorized. Removing..."
            Remove-UnauthorizedUser -username $User.Name
        }
    }

    # Get current Administrators group members
    $AdministratorsGroup = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name

    # Remove unauthorized admins
    foreach ($admin in $AdministratorsGroup) {
        if ($admin -notin $AuthorizedAdmins -and $admin -ne "Administrator") {
            Write-Host "Removing unauthorized admin account: $admin"
            Remove-LocalGroupMember -Group "Administrators" -Member $admin
        }
    }

    # Ensure authorized admins are in the Administrators group
    foreach ($admin in $AuthorizedAdmins) {
        if ($AdministratorsGroup -notcontains $admin) {
            $user = Get-LocalUser -Name $admin -ErrorAction SilentlyContinue
            if ($user) {
                Write-Host "Adding user '$admin' to the Administrators group."
                try {
                    Add-LocalGroupMember -Group "Administrators" -Member $admin -ErrorAction Stop
                } catch {
                    Write-Host "Failed to add user '$admin' to Administrators group. Error: $($_.Exception.Message)"
                }
            } else {
                Write-Host "User '$admin' does not exist. Cannot add to Administrators group."
            }
        }
    }

    # Ensure authorized users are not administrators if not specified
    foreach ($User in $AuthorizedUsers) {
        if ($User -notin $AuthorizedAdmins -and $AdministratorsGroup -contains $User) {
            Write-Host "Removing user '$User' from the Administrators group."
            Remove-LocalGroupMember -Group "Administrators" -Member $User
        }
    }

    # Disable the Guest account
    $GuestAccount = Get-LocalUser -Name "Guest" -ErrorAction SilentlyContinue
    If ($GuestAccount -and $GuestAccount.Enabled) {
        Write-Host "Disabling Guest account..."
        Disable-LocalUser -Name "Guest"
    }

    $doGroupShit= Get-YesNo "Do you want to manage groups?"
        
    if ($doGroupShit -eq 'Y') {
    # Define the group name
    $groupName = Read-Host "Enter the group name"

    # Check if the group already exists
    $groupExists = Get-LocalGroup -Name $groupName -ErrorAction SilentlyContinue

    if ($groupExists) {
        # If the group already exists, ask if the user wants to remove all existing users
        $removeUsers = Get-YesNo "The group '$groupName' already exists. Do you want to remove all users and replace them with new users?"
        
        if ($removeUsers -eq 'Y') {
            # Remove all users from the group
            Get-LocalGroupMember -Group $groupName | ForEach-Object {
                Remove-LocalGroupMember -Group $groupName -Member $_.Name
            }
        }
    } else {
        # Create a new group if it doesn't exist
        New-LocalGroup -Name $groupName
    }

    # Ask for users to add to the group
    $userNamesInput = Show-InputBox -title 'Group Users' -prompt 'Enter the usernames to add to the group from the read me'
    $userNames = ($userNamesInput -split "`n").Trim() | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    # Add each user to the group
    foreach ($user in $userNames) {
        $localUser = Get-LocalUser -Name $user -ErrorAction SilentlyContinue
        if ($localUser) {
            Add-LocalGroupMember -Group $groupName -Member $user -ErrorAction SilentlyContinue
        } else {
            Write-Host "User '$user' does not exist. Cannot add to group '$groupName'."
        }
    }

    Write-Host "Users have been added to the group '$groupName'."
} else {
    Write-Host "Skipping local user account management."
}
}

# ----------------------------------------------------
# Server Shit
# ----------------------------------------------------

if ($serverQuestionResponse -eq "y") {
# Start the job to check and install updates in the background
#Start-Job -ScriptBlock {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$regName = "NoAutoUpdate"
$desiredValue = 0

# Check if the registry path exists, create it if it doesn't
if (-not (Test-Path $regPath)) {
    Write-Output "Creating registry path: $regPath"
    New-Item -Path $regPath -Force | Out-Null
}

# Check the current value of the 'NoAutoUpdate' registry key
$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

# If the value doesn't exist, assume updates are disabled
if ($null -eq $currentValue) {
    Write-Output "'NoAutoUpdate' registry key not found. Assuming updates are disabled."
    $currentValue = 1 # Default to disabled if the value doesn't exist
}

# Enable Windows Automatic Updates by setting NoAutoUpdate to 0
if ($currentValue -ne $desiredValue) {
    Write-Output "Enabling Windows Automatic Updates..."
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Output "Windows Automatic Updates are now enabled."
} else {
    Write-Output "Windows Automatic Updates are already enabled."
}

# Optionally, ensure that the AUOptions setting is correctly configured (for example, to automatically download and install updates)
$auOptionsPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$auOptionsName = "AUOptions"
$desiredAUOptionsValue = 4  # This sets updates to automatically download and install

if (-not (Test-Path $auOptionsPath)) {
    Write-Output "Creating registry path: $auOptionsPath"
    New-Item -Path $auOptionsPath -Force | Out-Null
}

$currentAUOptions = Get-ItemProperty -Path $auOptionsPath -Name $auOptionsName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $auOptionsName -ErrorAction SilentlyContinue

# Set AUOptions if it's not configured correctly
if ($currentAUOptions -ne $desiredAUOptionsValue) {
    Write-Output "Setting AUOptions to $desiredAUOptionsValue (Automatic download and installation)..."
    Set-ItemProperty -Path $auOptionsPath -Name $auOptionsName -Value $desiredAUOptionsValue
    Write-Output "AUOptions set to $desiredAUOptionsValue. Automatic Updates will now be downloaded and installed automatically."
} else {
    Write-Output "AUOptions are already set correctly."
}

$wuauserv = Get-Service -Name wuauserv
if ($wuauserv.Status -ne 'Running') {
    Write-Output "Windows Update service is not running. Starting the service..."
    Start-Service -Name wuauserv
} else {
    Write-Output "Windows Update service is already running."
}

Write-Output "Manually checking for updates, downloading, and installing..."

try {
    # Start the update scan (Check for updates)
    Start-Process -FilePath "C:\Windows\System32\usoclient.exe" -ArgumentList "StartScan"
    Write-Output "Started the update check. This will trigger the 'Check for updates' process."

    # Start the download process (if updates are available)
    Start-Process -FilePath "C:\Windows\System32\usoclient.exe" -ArgumentList "StartDownload"
    Write-Output "Started downloading updates."

    # Start the installation process (Once download is done)
    Start-Process -FilePath "C:\Windows\System32\usoclient.exe" -ArgumentList "StartInstall"
    Write-Output "Started installing downloaded updates."

} catch {
    Write-Output "An error occurred while triggering the update process: $_"
}

Write-Output "Windows Automatic Updates are now fully enabled, and the update check, download, and installation have been triggered."
#} -ArgumentList $null

# ----------------------------------------------------
# Command 96: Uninstall BitTorrent if detected
# ----------------------------------------------------

Start-Job -ScriptBlock {
$bittorrentName = "BitTorrent"

# Check if BitTorrent is running
$bittorrentProcess = Get-Process -Name "bittorrent" -ErrorAction SilentlyContinue

if ($bittorrentProcess) {
    Write-Output "Stopping BitTorrent process..."
    Stop-Process -Name "bittorrent" -Force
    Write-Output "BitTorrent process has been stopped."
}

# Attempt to uninstall BitTorrent from AppData\Roaming
$bittorrentPath = "$env:APPDATA\BitTorrent"

if (Test-Path -Path "$bittorrentPath") {
    Write-Output "Found BitTorrent in AppData\Roaming. Removing..."
    Remove-Item -Path "$bittorrentPath" -Recurse -Force
    Write-Output "BitTorrent has been removed successfully."
}

if (-not (Get-Process -Name "bittorrent" -ErrorAction SilentlyContinue)) {
    Write-Output "BitTorrent is not installed or has been successfully removed."
} else {
    Write-Output "BitTorrent could not be uninstalled or was not found."
}
}

# ----------------------------------------------------
# Command 97: Uninstall Wireshark if detected
# ----------------------------------------------------

Start-Job -ScriptBlock {
$wiresharkName = "Wireshark"

# Check if Wireshark is running
$wiresharkProcess = Get-Process -Name "wireshark" -ErrorAction SilentlyContinue

if ($wiresharkProcess) {
    Write-Output "Stopping Wireshark process..."
    Stop-Process -Name "wireshark" -Force
    Write-Output "Wireshark process has been stopped."
}

# Attempt to uninstall Wireshark using the uninstall executable directly from its install location
$possiblePaths = @(
    "$env:ProgramFiles\Wireshark",
    "$env:ProgramFiles(x86)\Wireshark"
)

foreach ($path in $possiblePaths) {
    if (Test-Path -Path "$path\uninstall.exe") {
        Write-Output "Found Wireshark uninstall executable. Uninstalling..."
        Start-Process -FilePath "$path\uninstall.exe" -ArgumentList "/S" -NoNewWindow -Wait
        Write-Output "Wireshark has been uninstalled successfully."
        break
    }
}

if (-not (Get-Process -Name "wireshark" -ErrorAction SilentlyContinue)) {
    Write-Output "Wireshark is not installed or has been successfully removed."
} else {
    Write-Output "Wireshark could not be uninstalled or was not found."
}
}

# ----------------------------------------------------
# Command 98: Removed Adaware Web Companion
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Check if the application is running and close it if necessary
$processName = "WebCompanion"
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($process) {
    Write-Output "Web Companion is running. Attempting to close it..."
    Stop-Process -Name $processName -Force
    Start-Sleep -Seconds 3
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($process) {
        Write-Output "Failed to close Web Companion process. Please ensure no other program is using it and try again."
        exit 1
    }
    Write-Output "Web Companion process stopped."
} else {
    Write-Output "Web Companion process is not running."
}

# Delete the Web Companion executable
$webCompanionExePath = "C:\Program Files (x86)\Lavasoft\Web Companion\Application\WebCompanion.exe"
if (Test-Path -Path $webCompanionExePath) {
    try {
        Write-Output "Attempting to delete Web Companion executable..."
        Remove-Item -Path $webCompanionExePath -Force -ErrorAction Stop
        Write-Output "Web Companion executable successfully deleted."
    } catch {
        Write-Output "Failed to delete Web Companion executable. Please check permissions or try running PowerShell as an administrator."
    }
} else {
    Write-Output "Web Companion executable not found. It may have already been removed."
}
}

# ----------------------------------------------------
# Command 99: Limit local use of blank passwords to console only
# ----------------------------------------------------

Start-Job -ScriptBlock {
Write-Output "Ensuring local use of blank passwords is limited to console logon only..."
try {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -Value 1 -ErrorAction Stop
    Write-Output "Local use of blank passwords limited to console logon only."
} catch {
    Write-Output "Failed to set policy to limit local use of blank passwords. Please check permissions or try running PowerShell as an administrator."
}
}

# ----------------------------------------------------
# Firefox shit to do after firefox is updated
# ----------------------------------------------------

Start-Job -ScriptBlock {
# Firefox popup blocker enabled
$firefoxPrefsPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
$profileDirs = Get-ChildItem -Path $firefoxPrefsPath -Directory -ErrorAction SilentlyContinue

if ($profileDirs) {
    foreach ($profile in $profileDirs) {
        $prefsFile = "$($profile.FullName)\prefs.js"
        if (Test-Path $prefsFile) {
            Write-Output "Enabling popup blocker for Firefox profile: $($profile.Name)"
            Add-Content -Path $prefsFile -Value 'user_pref("dom.disable_open_during_load", true);'
            Write-Output "Popup blocker enabled for Firefox profile: $($profile.Name)"
        } else {
            Write-Output "prefs.js not found in profile: $($profile.Name)"
        }
    }
} else {
    Write-Output "No Firefox profiles found."
}
}

Start-Job -ScriptBlock {
# Enable "Block dangerous and deceptive content" in Firefox
$firefoxPrefsPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
$profileDirs = Get-ChildItem -Path $firefoxPrefsPath -Directory -ErrorAction SilentlyContinue

if ($profileDirs) {
    foreach ($profile in $profileDirs) {
        $prefsFile = "$($profile.FullName)\prefs.js"
        if (Test-Path $prefsFile) {
            Write-Output "Enabling 'Block dangerous and deceptive content' for Firefox profile: $($profile.Name)"
            Add-Content -Path $prefsFile -Value 'user_pref("browser.safebrowsing.malware.enabled", true);'
            Add-Content -Path $prefsFile -Value 'user_pref("browser.safebrowsing.phishing.enabled", true);'
            Write-Output "'Block dangerous and deceptive content' enabled for Firefox profile: $($profile.Name)"
        } else {
            Write-Output "prefs.js not found in profile: $($profile.Name)"
        }
    }
} else {
    Write-Output "No Firefox profiles found."
}
}

Start-Job -ScriptBlock {
# Disable Firefox profiles and sync
$firefoxPrefsPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
$profileDirs = Get-ChildItem -Path $firefoxPrefsPath -Directory -ErrorAction SilentlyContinue

if ($profileDirs) {
    foreach ($profile in $profileDirs) {
        $prefsFile = "$($profile.FullName)\prefs.js"
        if (Test-Path $prefsFile) {
            Write-Output "Disabling profiles and sync for Firefox profile: $($profile.Name)"
            Add-Content -Path $prefsFile -Value 'user_pref("services.sync.enabled", false);'
            Write-Output "Profiles and sync disabled for Firefox profile: $($profile.Name)"
        } else {
            Write-Output "prefs.js not found in profile: $($profile.Name)"
        }
    }
} else {
    Write-Output "No Firefox profiles found."
}
}
} else {
    Write-Output "Skipping server stuff."
}

# ----------------------------------------------------
# Ask User if They Want to start back up the disabled shit
# ----------------------------------------------------

# Prompt User to Clean Up and Restart
$cleanupResponse = Read-Host "Do you want to re-enable the firewall? (y/n)"
if ($cleanupResponse -eq "y") {
    Start-Job -ScriptBlock {
        try {
  	  # Enable Windows Defender ATP with PowerShell
   	 Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction Stop
  	  Write-Output "Controlled folder access enabled."
        
 	   # Enable cloud-delivered protection and automatic sample submission
 	   Set-MpPreference -MAPSReporting Advanced -SubmitSamplesConsent SendSafeSamples -ErrorAction Stop
  	  Write-Output "Cloud-delivered protection and automatic sample submission enabled."
        
 	   # Turn on real-time protection
 	   Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
 	   Write-Output "Real-time protection enabled."
	} catch {
	    Write-Output "Failed to configure Windows Defender ATP: $($_.Exception.Message)"
	}
	Write-Output "Windows Defender ATP configuration completed."
    }
} else {
    Write-Output "Didnt start the firewall."
}

# ----------------------------------------------------
# Ask User if They Want to Restart
# ----------------------------------------------------

# Prompt User to Clean Up and Restart
$cleanupResponse = Read-Host "Do you want to clean up temporary files and restart the system? (y/n)"
if ($cleanupResponse -eq "y") {
    Start-Job -ScriptBlock {
        Write-Output "Cleaning up temporary files..."
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Output "Temporary files cleaned up."
        Write-Output "Restarting the system..."
        Restart-Computer -Force
    }
} else {
    Write-Output "Cleanup and restart skipped."
}
