# Import the Active Directory module
Import-Module ActiveDirectory

# Enter the groupname
$groupName = Read-Host -Prompt "Enter the groupname"

# Get all users from group
$groupMembers = Get-ADGroupMember -Identity $groupName -Recursive | Where-Object { $_.objectClass -eq 'user' }

# Create an array to store user information
$userList = @()

# Check if the group exists and contains users
if ($groupMembers -ne $null -and $groupMembers.Count -gt 0) {
    # Go through each user and retrieve the necessary data
    foreach ($member in $groupMembers) {
        $user = Get-ADUser -Identity $member.SamAccountName -Properties DisplayName, EmailAddress, Enabled
        # Check that user is active
        if ($user.Enabled -eq $true) {
            $userInfo = New-Object PSObject -Property @{
                "ФИО" = $user.DisplayName
                "Почта" = $user.EmailAddress
            }
            $userList += $userInfo
        }
    }

    # Path for CSV file
    $outputFile = Read-Host -Prompt "Enter path for CSV (example, C:\path\to\output\active_group_members.csv)"

    # Info in CSV about users 
    $userList | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

    Write-Host "Active users in CSV $outputFile"
} else {
    Write-Host "Group $groupName not found or has no users."