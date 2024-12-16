Start-Job -ScriptBlock {
# Deny local logon for Remote Desktop Users
$localPolicyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$denyLogonLocally = "SeDenyInteractiveLogonRight"
$group = "Remote Desktop Users"

# Get the current list of groups/users denied local logon
$currentValue = (Get-ItemProperty -Path $localPolicyPath -Name $denyLogonLocally -ErrorAction SilentlyContinue).$denyLogonLocally

if ($currentValue -notlike "*$group*") {
    Write-Output "Denying local logon for Remote Desktop Users..."
    $newValue = if ($currentValue) { "$currentValue,$group" } else { "$group" }
    Set-ItemProperty -Path $localPolicyPath -Name $denyLogonLocally -Value $newValue
    Write-Output "Remote Desktop Users are now denied local logon."
} else {
    Write-Output "Remote Desktop Users are already denied local logon."
}

}