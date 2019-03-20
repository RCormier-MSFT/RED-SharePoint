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

    if($host.Version.Major -lt 5)
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
        $SourceEntries = (Get-Content $SourceManifest.LocalPath | Out-String | ConvertFrom-Json)
    }
    $WebsWithUniquePermissions = ($SourceEntries | where-object {($_.'Type of Entry' -eq "Web") -and ($_.'Has Unique Permissions' -eq "True")} | Select-Object 'Web URL')
    Return $WebsWithUniquePermissions
}