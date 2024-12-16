Start-Job -ScriptBlock {
$shares = Get-WmiObject -Query "SELECT * FROM Win32_Share" | Where-Object { $_.Name -like '*$' }

foreach ($share in $shares) {
    Write-Output "Removing hidden network share: $($share.Name)"
    Remove-WmiObject -Path $share.__PATH
}

Write-Output "All hidden network shares have been removed."
}