Start-Job -ScriptBlock {
# Grant full control over C:\ftp to a specified user group
$ftpFolderPath = "C:\ftp"
$ftpUsersGroup = "ftpusers"

# Create the folder if it does not exist
if (-not (Test-Path -Path $ftpFolderPath)) {
    Write-Output "Folder C:\ftp does not exist. Creating the folder..."
    New-Item -Path $ftpFolderPath -ItemType Directory | Out-Null
}

# Get the ACL for the folder and set permissions
$acl = Get-Acl -Path $ftpFolderPath
$ftpUsers = New-Object System.Security.Principal.NTAccount($ftpUsersGroup)
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($ftpUsers, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

$acl.SetAccessRule($accessRule)
Set-Acl -Path $ftpFolderPath -AclObject $acl

Write-Output "Full control over C:\ftp has been granted to $ftpUsersGroup."
}