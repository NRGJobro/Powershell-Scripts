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