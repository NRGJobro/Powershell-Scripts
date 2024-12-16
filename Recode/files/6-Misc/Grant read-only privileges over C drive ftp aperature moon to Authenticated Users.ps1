Start-Job -ScriptBlock { #read-only aperture-moon
# Grant read-only privileges over C:\ftp\aperture-moon to Authenticated Users
$folderPath = "C:\ftp\aperture-moon"
$authUsersGroup = "Authenticated Users"

# Create the folder if it does not exist
if (-not (Test-Path -Path $folderPath)) {
    Write-Output "Folder C:\ftp\aperture-moon does not exist. Creating the folder..."
    New-Item -Path $folderPath -ItemType Directory | Out-Null
}

# Get the ACL for the folder and set permissions
$acl = Get-Acl -Path $folderPath
$authUsers = New-Object System.Security.Principal.NTAccount($authUsersGroup)
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($authUsers, "Read", "ContainerInherit,ObjectInherit", "None", "Allow")

$acl.SetAccessRule($accessRule)
Set-Acl -Path $folderPath -AclObject $acl

Write-Output "Read-only privileges over C:\ftp\aperture-moon have been granted to Authenticated Users."
}