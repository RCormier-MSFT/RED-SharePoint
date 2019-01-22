function Get-WebsWithUniquePermissionsFromMigrationManifest
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$True, position=0, HelpMessage="This should be a JSON file that was generated using New-SourceMigrationManifest")]
        [ValidateScript({
            if($_.localpath.endswith("json")){$True}else{throw "`r`n`'InputFile`' must be a JSON file"}
            if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
        })]
        [URI]$SourceManifest
    )

    $SourceEntries = Get-Content $SourceManifest.localpath | ConvertFrom-Json
    $WebsWithUniquePermissions = ($SourceEntries | where-object {($_.'Type of Entry' -eq "Web") -and ($_.'Has Unique Permissions' -eq "True")} | Select-Object 'Web URL')
    Return $WebsWithUniquePermissions
}