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
# Ask User if They Want to start back up the disabled shit
# ----------------------------------------------------

# Prompt User to Clean Up and Restart
$cleanupResponse = Read-Host "Do you want to re-enable the firewall? (Y/N)"
if ($cleanupResponse -eq "yes") {
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
$cleanupResponse = Read-Host "Do you want to clean up temporary files and restart the system? (Y/N)"
if ($cleanupResponse -eq "yes") {
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
