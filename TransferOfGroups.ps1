# Import the Active Directory module
Import-Module ActiveDirectory

# Function to get user groups
function Get-UserGroups {
    param (
        [string]$username
    )

    $user = Get-ADUser -Identity $username -Properties MemberOf
    $groups = @()

    if ($user -ne $null) {
        $user.MemberOf | ForEach-Object {
            $group = Get-ADGroup -Identity $_
            $groups += $group.Name
        }
    }

    return $groups
}

# Function to set user groups
function Set-UserGroups {
    param (
        [string]$username,
        [array]$groups
    )

    $currentGroups = Get-UserGroups -username $username
    $groupsToAdd = $groups | Where-Object { $currentGroups -notcontains $_ }
    $groupsToRemove = $currentGroups | Where-Object { $groups -notcontains $_ }

    foreach ($group in $groupsToAdd) {
        Add-ADGroupMember -Identity $group -Members $username
    }

    foreach ($group in $groupsToRemove) {
        Remove-ADGroupMember -Identity $group -Members $username
    }
}

# Get the reference (source) and target users
$referenceUser = Read-Host "Enter the reference (source) username"
$targetUser = Read-Host "Enter the target username"

# Get groups of the reference user
$referenceUserGroups = Get-UserGroups -username $referenceUser

# Set groups to the target user
Set-UserGroups -username $targetUser -groups $referenceUserGroups

Write-Host "Groups $referenceUserGroups from $referenceUser have been copied to $targetUser."
