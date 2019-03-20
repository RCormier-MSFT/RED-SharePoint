
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

    if($Host.version.Major -lt 5)
    {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
        $jsonserial= New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
        $jsonserial.MaxJsonLength = 67108864
        [System.Object]$Results = $jsonserial.DeserializeObject((Get-Content $SourceManifest.LocalPath))

        $SourceEntries = New-Object System.Collections.ArrayList
        foreach($Entry in $Results)
        {
            $CurrentEntry = New-Object PSObject -Property $Entry
            $SourceEntries.Add($CurrentEntry) | Out-Null
        }
    }
    else
    {
        $SourceEntries = Get-Content $SourceManifest.LocalPath | ConvertFrom-Json
    }
    $WebsWithUniquePermissions = Get-WebsWithUniquePermissionsFromMigrationManifest -SourceManifest $SourceManifest.LocalPath
    foreach($Web in $WebsWithUniquePermissions)
    {
        $WebAssociatedGroups = Get-SPWebAssociatedGroupsFromMigrationManifest -WebURL $Web.'Web URL' -SourceManifest $SourceManifest.LocalPath
        $Entry = $SourceEntries | Where-Object {($_.'Type of Entry' -eq "Web") -and ($_.'Web URL' -eq $Web.'Web URL')}
        $WebURL = $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/")))
        Set-SPOAssociatedGroups -SiteURI $WebURL -Credential $Credential -AssociatedVisitorGroup $WebAssociatedGroups.VisitorGroup -AssociatedMemberGroup $WebAssociatedGroups.MemberGroup -AssociatedOwnerGroup $WebAssociatedGroups.OwnerGroup
    }
}
