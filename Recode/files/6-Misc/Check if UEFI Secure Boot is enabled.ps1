Start-Job -ScriptBlock { #Manually do UEIF in BIOS
# Check if UEFI Secure Boot is enabled
   $secureBoot = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue

   if ($secureBoot -eq $false) {
       Write-Output "UEFI Secure Boot is not enabled or not supported on this system. Please enable it manually in the BIOS/UEFI settings."
   } else {
       Write-Output "UEFI Secure Boot is enabled."
   }
}