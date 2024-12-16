Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Function Show-InputBox {
    param (
        [string]$title,
        [string]$prompt
    )
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $title
    $form.Width = 500
    $form.Height = 400
    $form.StartPosition = 'CenterScreen'

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $prompt
    $label.AutoSize = $true
    $label.Location = '10,20'
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Width = 460
    $textBox.Height = 250
    $textBox.Location = '10,50'
    $textBox.Multiline = $true
    $textBox.ScrollBars = 'Vertical'
    $form.Controls.Add($textBox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = 'OK'
    $okButton.Location = '200,320'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($okButton)

    $form.AcceptButton = $okButton

    if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $textBox.Text
    }
    return ''
}

# Function to get a Yes/No response
Function Get-YesNo($prompt) {
    do {
        $response = Read-Host "$prompt (Y/N)"
    } until ($response -match '^[YyNn]$')
    return $response.ToUpper()
}

# Function to automatically set a secure password for a user
Function Set-SecurePassword($username) {
    $Password = ConvertTo-SecureString -String "CyberPatri0t!?@" -AsPlainText -Force
    $user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
    if ($user) {
        try {
            $user | Set-LocalUser -Password $Password
        } catch {
            Write-Host "Failed to set password for user '$username'. Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "User '$username' does not exist. Cannot set password."
    }
}

# Function to remove unauthorized users
Function Remove-UnauthorizedUser($username) {
    try {
        Remove-LocalUser -Name $username -ErrorAction Stop
        Write-Host "User '$username' has been removed successfully."
    } catch {
        Write-Host "Failed to remove user '$username'. Error: $($_.Exception.Message)"
    }
}

# Function to parse authorized users and admins from input
Function Parse-AuthorizedUsers {
    param (
        [string]$inputText
    )
    
    $authorizedAdmins = @()
    $authorizedUsers = @()

    $lines = $inputText -split "`n"
    $section = ''

    foreach ($line in $lines) {
        $line = $line.Trim()
        if ($line -like 'Authorized Administrators:*') {
            $section = 'admins'
        } elseif ($line -like 'Authorized Users:*') {
            $section = 'users'
        } elseif ($line -ne '' -and $section -eq 'admins') {
            if ($line -like '*password:*') {
                continue
            }
            $authorizedAdmins += ($line -split '\s+')[0]
        } elseif ($line -ne '' -and $section -eq 'users') {
            $authorizedUsers += $line
        }
    }

    return [PSCustomObject]@{
        Admins = $authorizedAdmins
        Users = $authorizedUsers
    }
}

# Manage local user accounts if needed
$ManageUsers = Get-YesNo "Do you need to manage local user accounts?"

If ($ManageUsers -eq "Y") {
    # Manage local user accounts if needed
    $readmeInput = Show-InputBox -title 'Read Me Users' -prompt 'Paste the authorized users and admins from the readme file here'
    $parsedData = Parse-AuthorizedUsers -inputText $readmeInput

    $AuthorizedUsers = $parsedData.Users
    $AuthorizedAdmins = $parsedData.Admins

    Write-Host "Managing local user accounts..."

    # Get all local users excluding built-in accounts
    $LocalUsers = Get-LocalUser | Where-Object { $_.Name -ne "Administrator" -and $_.Name -ne "Guest" -and $_.Name -ne "DefaultAccount" -and $_.Name -ne "WDAGUtilityAccount" }

    # Set secure passwords for authorized users
    $AuthorizedUsers = $AuthorizedUsers | Sort-Object
    $LocalUsers = $LocalUsers | Sort-Object Name

    foreach ($User in $LocalUsers) {
        if ($User.Name -in $AuthorizedUsers -or $User.Name -in $AuthorizedAdmins) {
            Write-Host "User '$($User.Name)' is authorized. Setting a secure password..."
            Set-SecurePassword -username $User.Name
        } else {
            Write-Host "User '$($User.Name)' is not authorized. Removing..."
            Remove-UnauthorizedUser -username $User.Name
        }
    }

    # Get current Administrators group members
    $AdministratorsGroup = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name

    # Remove unauthorized admins
    foreach ($admin in $AdministratorsGroup) {
        if ($admin -notin $AuthorizedAdmins -and $admin -ne "Administrator") {
            Write-Host "Removing unauthorized admin account: $admin"
            Remove-LocalGroupMember -Group "Administrators" -Member $admin
        }
    }

    # Ensure authorized admins are in the Administrators group
    foreach ($admin in $AuthorizedAdmins) {
        if ($AdministratorsGroup -notcontains $admin) {
            $user = Get-LocalUser -Name $admin -ErrorAction SilentlyContinue
            if ($user) {
                Write-Host "Adding user '$admin' to the Administrators group."
                try {
                    Add-LocalGroupMember -Group "Administrators" -Member $admin -ErrorAction Stop
                } catch {
                    Write-Host "Failed to add user '$admin' to Administrators group. Error: $($_.Exception.Message)"
                }
            } else {
                Write-Host "User '$admin' does not exist. Cannot add to Administrators group."
            }
        }
    }

    # Ensure authorized users are not administrators if not specified
    foreach ($User in $AuthorizedUsers) {
        if ($User -notin $AuthorizedAdmins -and $AdministratorsGroup -contains $User) {
            Write-Host "Removing user '$User' from the Administrators group."
            Remove-LocalGroupMember -Group "Administrators" -Member $User
        }
    }

    # Disable the Guest account
    $GuestAccount = Get-LocalUser -Name "Guest" -ErrorAction SilentlyContinue
    If ($GuestAccount -and $GuestAccount.Enabled) {
        Write-Host "Disabling Guest account..."
        Disable-LocalUser -Name "Guest"
    }

    $doGroupShit= Get-YesNo "Do you want to manage groups?"
        
    if ($doGroupShit -eq 'Y') {
    # Define the group name
    $groupName = Read-Host "Enter the group name"

    # Check if the group already exists
    $groupExists = Get-LocalGroup -Name $groupName -ErrorAction SilentlyContinue

    if ($groupExists) {
        # If the group already exists, ask if the user wants to remove all existing users
        $removeUsers = Get-YesNo "The group '$groupName' already exists. Do you want to remove all users and replace them with new users?"
        
        if ($removeUsers -eq 'Y') {
            # Remove all users from the group
            Get-LocalGroupMember -Group $groupName | ForEach-Object {
                Remove-LocalGroupMember -Group $groupName -Member $_.Name
            }
        }
    } else {
        # Create a new group if it doesn't exist
        New-LocalGroup -Name $groupName
    }

    # Ask for users to add to the group
    $userNamesInput = Show-InputBox -title 'Group Users' -prompt 'Enter the usernames to add to the group from the read me'
    $userNames = ($userNamesInput -split "`n").Trim() | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    # Add each user to the group
    foreach ($user in $userNames) {
        $localUser = Get-LocalUser -Name $user -ErrorAction SilentlyContinue
        if ($localUser) {
            Add-LocalGroupMember -Group $groupName -Member $user -ErrorAction SilentlyContinue
        } else {
            Write-Host "User '$user' does not exist. Cannot add to group '$groupName'."
        }
    }

    Write-Host "Users have been added to the group '$groupName'."
} else {
    Write-Host "Skipping local user account management."
}
}