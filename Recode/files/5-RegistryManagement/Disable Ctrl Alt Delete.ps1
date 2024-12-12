Start-Job -ScriptBlock {
    # Disable requirement for Ctrl+Alt+Delete at login

    # Modify registry to disable secure sign-in (Ctrl+Alt+Delete)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Value 1
    Write-Output "Requirement for Ctrl+Alt+Delete at login disabled."

    # Verify the settings
    $secureSignInStatus = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD"
    if ($secureSignInStatus.DisableCAD -eq 1) {
        Write-Output "Secure sign-in successfully disabled."
    } else {
        Write-Output "Failed to disable secure sign-in."
    }
}