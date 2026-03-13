# Author: Ahsaan Patterson
# Project: IAM User Lifecycle Automation Lab
# Description:
# Automates onboarding and offboarding of users in Active Directory using CSV input.
# Demonstrates IAM lifecycle management including provisioning, RBAC group assignment,
# and automated deprovisioning workflows.

Import-Module ActiveDirectory

# --- Configuration ---
$CsvPath     = "C:\Users\Administrator\IAMLab\new_users.csv"
$LogPath     = "C:\Users\Administrator\IAMLab\Logs\provisioning.log"
$TargetOU    = "CN=Users,DC=lab,DC=local"
$DefaultPass = "TempPass2026!"

# Department to group mapping
$DepartmentGroups = @{
    "Finance" = @("GRP_Finance_Read","GRP_VPN_Users")
    "HR"      = @("GRP_HR_Read","GRP_VPN_Users")
    "Trading" = @("GRP_Trading_AppUsers","GRP_VPN_Users")
}

# Create log file if needed
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType File -Force | Out-Null
}

function Write-Log {
    param ([string]$Message)

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$Timestamp] $Message"
}

# Verify CSV exists
if (-not (Test-Path $CsvPath)) {
    Write-Host "CSV file not found: $CsvPath" -ForegroundColor Red
    Write-Log "ERROR: CSV file not found."
    exit
}

$Users = Import-Csv $CsvPath

foreach ($User in $Users) {

    $FirstName  = $User.FirstName
    $LastName   = $User.LastName
    $Username   = $User.Username
    $Department = $User.Department
    $Role       = $User.Role

    $DisplayName = "$FirstName $LastName"
    $UPN = "$Username@lab.local"

    try {

        $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue

        if ($ExistingUser) {

            Write-Host "User $Username already exists. Skipping."
            Write-Log "SKIP: $Username already exists."

            continue
        }

        # Create user
        New-ADUser `
            -Name $DisplayName `
            -GivenName $FirstName `
            -Surname $LastName `
            -SamAccountName $Username `
            -UserPrincipalName $UPN `
            -DisplayName $DisplayName `
            -Department $Department `
            -Title $Role `
            -Path $TargetOU `
            -AccountPassword (ConvertTo-SecureString $DefaultPass -AsPlainText -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Created user: $Username"
        Write-Log "SUCCESS: Created user $Username."

        # Assign groups
        if ($DepartmentGroups.ContainsKey($Department)) {

            foreach ($Group in $DepartmentGroups[$Department]) {

                Add-ADGroupMember -Identity $Group -Members $Username

                Write-Host "Added $Username to $Group"
                Write-Log "SUCCESS: Added $Username to $Group."
            }
        }

    }

    catch {

        Write-Host "Failed creating user $Username"
        Write-Log "ERROR: Failed creating $Username."
    }
}
