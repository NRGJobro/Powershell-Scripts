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