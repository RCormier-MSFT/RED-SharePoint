function Get-SPWebRolesMigrationManifestInfo
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This parameter requires an SPWeb object to be passed", ValueFromPipeline=$True, ValueFromPipelineByPropertyName)]
    [Alias('URL')]
    [Microsoft.SharePoint.SPWeb]$SPWeb
    )
    $WebRolesEntries = New-Object System.Collections.ArrayList
    if($Web.IsRootWeb)
    {
        foreach($role in $Web.Roles)
        {
            $RoleEntry = New-Object System.Object
            $RoleEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Role"
            $RoleEntry | Add-Member -MemberType NoteProperty -Name "Role Name" -Value "$($Role.Name)"
            $RoleEntry | Add-Member -MemberType NoteProperty -Name "Permission Mask" -Value "$($Role.PermissionMask)"
            $WebRolesEntries.add($RoleEntry)
        }
    }
    else
    {
        Return $null
    }
}