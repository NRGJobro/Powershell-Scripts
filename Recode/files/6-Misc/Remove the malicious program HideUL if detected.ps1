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