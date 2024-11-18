Start-Job -ScriptBlock {
    $mp3Files = Get-ChildItem -Path "C:\" -Filter "*.mp3" -Recurse -ErrorAction SilentlyContinue
    if ($mp3Files) {
        $mp3Files | Remove-Item -Force
        Write-Output "Prohibited MP3 files removed."
    } else {
        Write-Output "No prohibited MP3 files found."
    }
}