
function New-SPOBulkAssociatedGroupsUpdate
{
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This should be a JSON file that was generated using New-SourceMigrationManifest")]
    [ValidateScript({
        if($_.localpath.endswith("json")){$True}else{throw "`r`n`'InputFile`' must be a JSON file"}
        if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
    })]
    [URI]$SourceManifest,
    [parameter(Mandatory=$False, position=2, HelpMessage="Supply a credential object to connect to SharePOint Online")]
    [System.Management.Automation.PSCredential]$Credential
    )

    $WebsWithUniquePermissions = Get-WebsWithUniquePermissionsFromMigrationManifest -SourceManifest $SourceManifest.LocalPath
    foreach($Web in $WebsWithUniquePermissions)
    {
        $WebAssociatedGroups = Get-SPWebAssociatedGroupsFromMigrationManifest -WebURL $Web.'Web URL' -SourceManifest $SourceManifest.LocalPath
        Set-SPOAssociatedGroups -SiteURI $web -Credential $Credential -AssociatedVisitorGroup $WebAssociatedGroups.VisitorGroup -AssociatedMemberGroup $WebAssociatedGroups.MemberGroup -AssociatedOwnerGroup $WebAssociatedGroups.OwnerGroup
    }
}
