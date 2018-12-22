Function Get-SPOWebGroupValidation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$True, position=0)]
    [System.Object[]]$Entry,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential,
    [parameter(Mandatory=$False, position=2, HelpMessage="Use the -GroupExclusionFile parameter to specify a text file containing a list groups that should be evaluated for exclusion.")]
    [ValidateScript({
        if($_.localpath.endswith("txt")){$True}else{throw "`r`n`'InputFile`' must be a txt file"}
        if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
    })]
    [URI]$GroupExclusionFile
    )

    if($GroupExclusionFile)
    {
        $GroupExclusions = Get-Content $GroupExclusionFile.LocalPath
    }
    Connect-PnPOnline -Url $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/"))) -Credentials $Credential | Out-Null
    $WebGroup = Get-PnPGroup -Identity $Entry.'Group Name' -ErrorAction SilentlyContinue
    $WebGroupEntry = New-Object System.Object
    $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $Entry.'Source Site URL'
    $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $Entry.'Destination Site URL'
    $WebGroupEntry | Add-Member -MemberType NoteProperty -name "Web URL" -Value (Get-PnPConnection | Select-Object URL)
    $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Group Name" -value $Entry.'Group Name'
    if($WebGroup)
    {
        $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Group"
        $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Exists in Destination Site" -Value "True"
        $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Source Members in Group" -Value $Entry.'Members in Group'
        $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Destination Members in Group" -Value $WebGroup.Users.Count
        if($GroupExclusionFile)
        {
            if($GroupExclusions -imatch $Entry.'Group Name')
            {
                $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Excluded Group" -Value "True"
            }
            else
            {
                $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Excluded Group" -Value "False"
            }
        }
    }
    else
    {
        $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Exists in Destination Site" -Value "False"
    }
    Return $WebGroupEntry
}