function Get-SPWebAssociatedGroupsFromMigrationManifest
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$True, position=0, HelpMessage="This should be a JSON file that was generated using New-SourceMigrationManifest")]
        [ValidateScript({
            if($_.localpath.endswith("json")){$True}else{throw "`r`n`'InputFile`' must be a JSON file"}
            if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
        })]
        [URI]$SourceManifest,
        [parameter(Mandatory=$True, Position=1, HelpMessage="Supply the URL of a web that exists in the source manifest file")]
        [URI]$WebURL
    )

    $SourceEntries = Get-Content $SourceManifest.LocalPath | ConvertFrom-Json
    $WebAssociations = New-Object System.Object
    $WebAssociations | Add-Member -MemberType NoteProperty -Name VisitorGroup -Value $($SourceEntries | Where-Object {($_.'Web URL' -eq $WebURL) -and ($_.IsAssociatedVisitorGroup)} | Select-Object -ExpandProperty 'Group Name')
    $WebAssociations | Add-Member -MemberType NoteProperty -Name MemberGroup -Value $($SourceEntries | Where-Object {($_.'Web URL' -eq $WebURL) -and ($_.IsAssociatedMemberGroup)} | Select-Object -ExpandProperty 'Group Name')
    $WebAssociations | Add-Member -MemberType NoteProperty -Name OwnerGroup -Value $($SourceEntries | Where-Object {($_.'Web URL' -eq $WebURL) -and ($_.IsAssociatedOwnerGroup)} | Select-Object -ExpandProperty 'Group Name')
    Return $WebAssociations
}
