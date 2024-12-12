Start-Job -ScriptBlock {
$notepadPlusPlusPath = "C:\Program Files\Notepad++\notepad++.exe"

if (Test-Path $notepadPlusPlusPath) {
    Write-Output "Checking for Notepad++ updates..."
    Start-Process -FilePath $notepadPlusPlusPath -ArgumentList "-updatecheck" -NoNewWindow -Wait
    Write-Output "Notepad++ update check complete."
} else {
    Write-Output "Notepad++ is not installed."
}
}