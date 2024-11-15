Import-Module ActiveDirectory

# Function to get members of a group
function Get-GroupMembers {
    param (
        [string]$groupname
    )

    $group = Get-ADGroup -Identity $groupname -Properties Members
    $members = @()

    if ($group -ne $null) {
        $group.Members | ForEach-Object {
            $user = Get-ADUser -Identity $_
            $members += $user.SamAccountName
        }
    }

    return $members
}

function Add-MembersToGroups {
    param (
        [array]$members,
        [array]$targetGroups
    )

    foreach ($targetGroup in $targetGroups) {
        foreach ($member in $members) {
            Add-ADGroupMember -Identity $targetGroup -Members $member
        }
    }
}

# Get the source group
$sourceGroup = Read-Host "Enter main group"

$targetGroupsInput = Read-Host "Enter the final groups sparated by commas"
$targetGroups = $targetGroupsInput -split ','

# Get members of the source group
$sourceGroupMembers = Get-GroupMembers -groupname $sourceGroup

# Add members to the target groups
Add-MembersToGroups -members $sourceGroupMembers -targetGroups $targetGroups

Write-Host "Users $sourceGroupMembers from $sourceGroup were transferred from the group : $targetGroups."
