
<#This code uses Service Principal with Self Signed Certificate to authenticate to MGGraph to pull all SSO enabled enterprise APP and export the assigned memebers/groups
to a csv and upload it to a SharePoint Site.

If it is running on a Windows PC locally, Microsoft.MGGraph SDK is recommended

If it is running in a Azure Automation runbook, the Automation account must have the following modules imported and have the modules called out in the PS code:
#>

#Modules required:
Import-Module Microsoft.Graph.Applications -Verbose:$false
Import-Module Microsoft.Graph.Authentication -Verbose:$false
Import-Module Microsoft.Graph.Users -Verbose:$false
Import-Module Microsoft.Graph.Groups -Verbose:$false
Import-Module Microsoft.Graph.Files -Verbose:$false
Import-Module Microsoft.Graph.Identity.DirectoryManagement -Verbose:$false
Import-Module Microsoft.Graph.sites -Verbose:$false
Import-Module Microsoft.Graph.DirectoryObjects -Verbose:$false

# Below is required if run directly from a PC
<#
$clientId = "9087070d-25c8-4249-b1a6-1d6456104584c"
$tenantId = "847511aa-62b7-475e-a134-1aa2c555620e"
$certThumbprint = "aa57b33eb7e9041b62e4cc2012d12f4e8cf4f245"
#>

# The following code is required for using the Azure Automation Connection for required values
# Requires an Automation Connection named 'sec_uar_automation_connect'
$connectionName = "sec_uar_automation_connect"
$connection = Get-AutomationConnection -Name $connectionName
$cert = Get-AutomationCertificate -Name "uar-automation-selfsigned-sp-cert"
$tenantId = $connection.TenantId
$application_id = $connection.ApplicationId

# Connect to Microsoft Graph with certificate
# Connect-MgGraph -ClientId $clientId -TenantId $tenantId -CertificateThumbprint $certThumbprint
Connect-MgGraph -ClientId $application_id -TenantId $tenantId -CertificateThumbprint $cert.Thumbprint
$sitename = "abits.com.au"
$libraryName = "Documents"

# Get the SharePoint site object using hostname and path
$site = Get-MgSite -Search $sitename

# Get the document library (drive)
$drive = Get-MgSiteDrive -SiteId $site.Id | Where-Object { $_.Name -eq $libraryName }

# Prepare local export folder
$dateStamp = Get-Date -Format 'yyyy-MM-dd'
$exportFolder = Join-Path -Path $env:TEMP -ChildPath "AppAssignments-$dateStamp"
New-Item -Path $exportFolder -ItemType Directory -Force | Out-Null

# Filter apps that are SSO enabled only
$apps = Get-MgServicePrincipal -Filter "Tags/any(t: t eq 'WindowsAzureActiveDirectoryIntegratedApp')"

foreach ($app in $apps) {
    $assignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $app.Id
    $output = @()

    foreach ($assignment in $assignments) {
        $assignee = Get-MgDirectoryObject -DirectoryObjectId $assignment.PrincipalId | Select-Object *

        if ($assignee.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group') {
            $groupMembers = Get-MgGroupMember -GroupId $assignee.Id -All
            foreach ($member in $groupMembers) {
                $upn = if ($member.UserPrincipalName) { $member.UserPrincipalName } else { $member.AdditionalProperties.userPrincipalName }
                $output += [PSCustomObject]@{
                    AppDisplayName = $app.DisplayName
                    AssigneeType = "GroupMember"
                    GroupName = $assignee.DisplayName
                    UserPrincipalName = $upn
                }
            }
        } elseif ($assignee.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user') {
            $upn = if ($assignee.UserPrincipalName) { $assignee.UserPrincipalName } else { $assignee.AdditionalProperties.userPrincipalName }
            $output += [PSCustomObject]@{
                AppDisplayName = $app.DisplayName
                AssigneeType = "User"
                GroupName = ""
                UserPrincipalName = $upn
            }
        }
    }

    if ($output.Count -gt 0) {
        $safeName = ($app.DisplayName -replace '[\/:*?"<>|]', '_')
        $csvPath = Join-Path -Path $exportFolder -ChildPath "$safeName.csv"
        $output | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    }
}

# Upload CSVs to SharePoint library folder (named by date)
$driveId = $drive.Id
$folderName = "Sec_UAR_App_Assignment-$dateStamp"

# Create folder in SharePoint using Graph API directly
#$folderItem = 
Invoke-MgGraphRequest -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/drives/$driveId/root/children" `
    -Body @{ 
        name = $folderName
        folder = @{}
        "@microsoft.graph.conflictBehavior" = "rename"
    }

# Upload each file to the SharePoint folder
Get-ChildItem -Path $exportFolder -Filter *.csv | ForEach-Object {
    $fileName = $_.Name
    $filePath = $_.FullName
    $contentBytes = [System.IO.File]::ReadAllBytes($filePath)

    # Build path-based Graph API URL
    $escapedFolder = [uri]::EscapeDataString($folderName)
    $escapedFileName = [uri]::EscapeDataString($fileName)
    $uploadUrl = "https://graph.microsoft.com/v1.0/drives/${driveId}/root:/${escapedFolder}/${escapedFileName}:/content"

    # PUT with raw bytes and correct content-type
    Invoke-MgGraphRequest -Method PUT `
        -Uri $uploadUrl `
        -Body $contentBytes `
        -Headers @{ "Content-Type" = "application/octet-stream" }
}


Write-Output "Upload complete: $($output.Count) CSVs to SharePoint folder '$folderName' in library '$libraryName'"
