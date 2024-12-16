Start-Job -ScriptBlock {
   Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" | foreach-object {
        auditpol /set /subcategory:* /success:enable /failure:enable
   }
}