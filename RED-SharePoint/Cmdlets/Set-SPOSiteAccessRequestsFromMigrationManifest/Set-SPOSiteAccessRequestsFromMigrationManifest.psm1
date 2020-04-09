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
    [parameter(Mandatory=$False, position=1)]
    [URI]$LogFolder,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
    )

    if($LogFolder)
    {
            if(-not $LogFolder.LocalPath)
        {
            $LogFolder = "$(get-location)\$($LogFolder.OriginalString)"
        }
        if(-not (Test-Path $LogFolder.LocalPath))
        {
            New-Item -ItemType Directory -Path $LogFolder.LocalPath
        }
    }
    else
    {
        $LogFolder = (Get-Location).path
    }

    $LogFile = "$($LogFolder.localpath)\Set-PNPAccessRequestEmails_$(Get-Date -Format dd-MM-yyyy_HH-mm-ss).csv"
    $LogData = New-Object System.Collections.ArrayList

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
        $LogEntry = New-Object System.Object
        $LogEntry | Add-Member -MemberType NoteProperty -Name Web -Value "$($Web.'Web url')"
        $Entry = $SourceEntries | Where-Object {($_.'Web URL' -eq $web.'Web URL')-and ($_.'Type of Entry' -eq "Web")}
        $LogEntry | Add-Member -MemberType NoteProperty -Name Email -Value "$($Entry.'Access Request Email')"
        if($Entry.'Access Request Email')
        {
            Connect-PnPOnline -Url ($Entry.'Web URL'.Replace($entry.'Source Site URL', $entry.'Destination Site URL')) -Credentials $Credential
            Try
            {
                Set-PnPRequestAccessEmails -Emails $Entry.'Access Request Email'
                $LogEntry | Add-Member -MemberType NoteProperty -Name Status -Value "Success"
            }
            Catch
            {
                $LogEntry | Add-Member -MemberType NoteProperty -Name Status -Value "Failed"
            }
            $LogData.Add($LogEntry) | Out-Null
            
        }
    }
    $LogData | Export-Csv -Path $LogFile -NoTypeInformation
}