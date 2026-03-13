# Author: Ahsaan Patterson
# Project: IAM User Lifecycle Automation Lab
# Description:
# Automates onboarding and offboarding of users in Active Directory using CSV input.
# Demonstrates IAM lifecycle management including provisioning, RBAC group assignment,
# and automated deprovisioning workflows.




Import-Module ActiveDirectory

# Configuration
$CsvPath = "C:\Users\Administrator\IAMLab\leavers.csv"
$LogPath = "C:\Users\Administrator\IAMLab\Logs\leavers.log"
$DisabledOU = "OU=DisabledUsers,DC=lab,DC=local"

# Create log file
if (-not (Test-Path $LogPath)) {

    New-Item -Path $LogPath -ItemType File -Force | Out-Null
}

function Write-Log {

    param([string]$Message)

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Add-Content -Path $LogPath -Value "[$Timestamp] $Message"
}

# Validate CSV
if (-not (Test-Path $CsvPath)) {

    Write-Host "CSV not found."
    Write-Log "ERROR: CSV not found."

    exit
}

$Leavers = Import-Csv $CsvPath

foreach ($Entry in $Leavers) {

    $Username = $Entry.Username
    $Ticket   = $Entry.Ticket
    $Reason   = $Entry.Reason

    try {

        $User = Get-ADUser $Username -Properties MemberOf

        # Remove group memberships except Domain Users
        $Groups = Get-ADPrincipalGroupMembership $Username |
                  Where-Object {$_.Name -ne "Domain Users"}

        foreach ($Group in $Groups) {

            Remove-ADGroupMember $Group -Members $Username -Confirm:$false

            Write-Host "Removed $Username from $Group"
            Write-Log "SUCCESS: Removed $Username from $Group"
        }

        # Disable account
        Disable-ADAccount $Username

        Write-Host "Disabled user: $Username"
        Write-Log "SUCCESS: Disabled user $Username"

        # Update description
        $Description = "Disabled on $(Get-Date -Format yyyy-MM-dd) | Ticket $Ticket | $Reason"

        Set-ADUser $Username -Description $Description

        # Move to DisabledUsers OU
        $DN = (Get-ADUser $Username).DistinguishedName

        Move-ADObject $DN -TargetPath $DisabledOU

        Write-Host "Moved $Username to DisabledUsers"
        Write-Log "SUCCESS: Moved $Username to DisabledUsers OU"

    }

    catch {

        Write-Host "Error processing $Username"
        Write-Log "ERROR processing $Username"
    }
}
