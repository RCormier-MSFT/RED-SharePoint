function Get-SPWebGroupsMigrationManifestInfo
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This parameter requires an SPWeb object to be passed", ValueFromPipeline=$True, ValueFromPipelineByPropertyName)]
    [Alias('URL')]
    [Microsoft.SharePoint.SPWeb]$SPWeb
    )

    $WebGroupsEntries = New-Object System.Collections.ArrayList
    if($SPWeb.IsRootWeb)
    {
        foreach($Group in $SPWeb.Groups)
        {
            $GroupEntry = New-Object System.Object
            $GroupEntry | Add-Member -MemberType NoteProperty -Name "Web URL" -Value "$($SPWeb.URL)"
            $GroupEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Group"
            $GroupEntry | Add-Member -MemberType NoteProperty -Name "Group Name" -Value "$($Group.Name)"
            $WebGroupsEntries.add($GroupEntry) | Out-Null
        }
        Return $WebGroupsEntries
    }
    else
    {
        Return $Null
    }

}