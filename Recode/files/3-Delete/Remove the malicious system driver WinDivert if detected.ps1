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