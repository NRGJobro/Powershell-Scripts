# Set the folder path to the directory where the script is located
$folderPath = $PSScriptRoot

# Get all the .ps1 files in the folder
$ps1Files = Get-ChildItem -Path $folderPath -Filter *.ps1

# Run each .ps1 file
foreach ($file in $ps1Files) {
    # Condition to skip files named 'SkipThisFile.ps1'
    if ($file.Name -eq 'AllCommands.ps1') {
        Write-Host "Skipping $($file.FullName)..."
        continue  # Skip to the next file in the loop
    }

    Write-Host "Running $($file.FullName)..."
    & $file.FullName  # Run the script
}

# Pause at the end to keep the window open
Read-Host "Press Enter to exit..."