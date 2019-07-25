function Set-SPOSiteAccessRequestsFromMigrationManifest
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This should be a JSON file that was generated using New-SPMigrationManifestValidationSummary cmdlet")]
    [ValidateScript({
        if($_.localpath.endswith("json")){$True}else{throw "`r`n`'InputFile`' must be a JSON file"}
        if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
    })]
    [URI]$SourceManifest,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
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
    $WebsToSet = Get-WebsWithUniquePermissionsFromMigrationManifest -SourceManifest $SourceManifest.LocalPath
    foreach($web in $WebsToSet)
    {
        $Entry = $SourceEntries | Where-Object {($_.'Web URL' -eq $web.'Web URL')-and ($_.'Type of Entry' -eq "Web")}
        if($Entry.'Access Request Email')
        {
            Connect-PnPOnline -Url ($Entry.'Web URL'.Replace($entry.'Source Site URL', $entry.'Destination Site URL')) -Credentials $Credential
            Set-PnPRequestAccessEmails -Emails $Entry.'Access Request Email'
        }
    }
}