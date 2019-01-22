function Get-SPWebGroupsMigrationManifestInfo
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This parameter requires an SPWeb object to be passed", ValueFromPipeline=$True, ValueFromPipelineByPropertyName)]
    [Alias('URL')]
    [Microsoft.SharePoint.SPWeb]$SPWeb,
    [parameter(Mandatory=$False, position=1, HelpMessage="Use the -GroupExclusionFile parameter to specify a text file containing a list groups that should be evaluated for exclusion.")]
    [ValidateScript({
        if($_.localpath.endswith("txt")){$True}else{throw "`r`n`'InputFile`' must be a txt file"}
        if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
    })]
    [URI]$GroupExclusionFile
    )

    $WebGroupsEntries = New-Object System.Collections.ArrayList
    if($SPWeb.HasUniquePerm)
    {
        if($GroupExclusionFile)
        {
            $GroupExclusions = Get-Content $GroupExclusionFile.LocalPath
        }
        foreach($Group in $SPWeb.Groups)
        {
            $GroupEntry = New-Object System.Object
            $GroupEntry | Add-Member -MemberType NoteProperty -Name "Web URL" -Value "$($SPWeb.URL)"
            $GroupEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Group"
            $GroupEntry | Add-Member -MemberType NoteProperty -Name "Group Name" -Value "$($Group.Name)"
            $GroupEntry | Add-Member -MemberType NoteProperty -Name "Members in Group" -Value "$($Group.Users.Count)"
            if($SPWeb.AssociatedVisitorGroup.Name -eq $Group.Name)
            {
                $GroupEntry | Add-Member -MemberType NoteProperty -Name "IsAssociatedVistorGroup" -Value $True
            }
            else
            {
                $GroupEntry | Add-Member -MemberType NoteProperty -Name "IsAssociatedVisitorGroup" -Value $False
            }
            if($SPWeb.AssociatedMemberGroup.Name -eq $Group.Name)
            {
                $GroupEntry | Add-Member -MemberType NoteProperty -Name "IsAssociatedMemberGroup" -Value $True
            }
            else
            {
                $GroupEntry | Add-Member -MemberType NoteProperty -Name "IsAssociatedMemberGroup" -Value $False
            }
            if($SPWeb.AssociatedOwnerGroup.Name -eq $Group.Name)
            {
                $GroupEntry | Add-Member -MemberType NoteProperty -Name "IsAssociatedOwnerGroup" -Value $True
            }
            else
            {
                $GroupEntry | Add-Member -MemberType NoteProperty -Name "IsAssociatedOwnerGroup" -Value $False
            }
            if($GroupExclusions)
            {
                if($GroupExclusions -imatch $Group.Name)
                {
                    $GroupEntry | Add-Member -MemberType NoteProperty -Name "Excluded Group" -Value "True"
                }
                else
                {
                    $GroupEntry | Add-Member -MemberType NoteProperty -Name "Excluded Group" -Value "False"
                }
            }
            $WebGroupsEntries.add($GroupEntry) | Out-Null
        }
        Return $WebGroupsEntries
    }
    else
    {
        Return $Null
    }

}