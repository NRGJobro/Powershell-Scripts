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