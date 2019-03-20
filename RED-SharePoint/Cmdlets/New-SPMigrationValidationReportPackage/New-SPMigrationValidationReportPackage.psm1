function New-SPMigrationValidationReportPackage
{
    [cmdletbinding(SupportsShouldProcess=$True)]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This should be a JSON file that was generated using New-SPMigrationManifestValidationSummary cmdlet")]
    [ValidateScript({
        if($_.localpath.endswith("json")){$True}else{throw "`r`n`'InputFile`' must be a JSON file"}
        if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
    })]
    [URI]$SourceManifest,
    [parameter(Mandatory=$False, position=1, HelpMessage="Use this switch to force overwriting existing summary package")]
    [Switch]$Force
    )
    if(!($Force) -and ((Test-Path ($SourceManifest.LocalPath.replace(".json", "_Sites.csv"))) -or (Test-Path ($SourceManifest.LocalPath.replace(".json", "Lists.csv"))) -or (Test-Path ($SourceManifest.LocalPath.replace(".json", "_Webs.csv")))))
    {
        Write-Host "Report Package already exists`r`nUse the `'-Force`' switch to overwrite existing files" -ForegroundColor Red
    }
    else
    {
        if($Host.Version.Major -lt 5)
        {
            [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
            $jsonserial= New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
            $jsonserial.MaxJsonLength = 67108864
            [System.Object]$Results = $jsonserial.DeserializeObject((Get-Content $SourceManifest.LocalPath))

            $ValidationSummary = New-Object System.Collections.ArrayList
            foreach($Entry in $Results)
            {
                $CurrentEntry = New-Object PSObject -Property $Entry
                $ValidationSummary.Add($CurrentEntry) | Out-Null
            }

        }
        else
        {
            $ValidationSummary = (Get-Content $SourceManifest.LocalPath -Raw | ConvertFrom-Json)
        }

        $Mode = $ValidationSummary | where-object {$_.'Type of Entry' -eq "ReportInfo"} | Select-Object -ExpandProperty Mode
        Write-Host "Report mode is $($Mode)" -ForegroundColor Yellow
        if(($Mode -eq "FullReport") -or ($Mode -eq "Structure"))
        {
            $ValidationSummary | Where-Object {$_."Type of Entry" -eq "Site"} | Export-Csv -Path $SourceManifest.LocalPath.replace(".json", "_Sites.csv") -NoTypeInformation -Force
            $ValidationSummary | Where-Object {$_."Type of Entry" -eq "Web"} | Export-Csv -Path $SourceManifest.LocalPath.replace(".json", "_Webs.csv") -NoTypeInformation -Force
            Write-Host "Created Site and Web Report" -ForegroundColor Green
        }
        if(($Mode -eq "FullReport") -or ($Mode -eq "ItemCount"))
        {
            $ValidationSummary | Where-Object {$_."Type of Entry" -eq "List"} | Export-Csv -Path $SourceManifest.LocalPath.replace(".json", "_Lists.csv") -NoTypeInformation -Force
            $ValidationSummary | Where-Object {$_."Type of Entry" -eq "Web"} | Export-Csv -Path $SourceManifest.LocalPath.Replace(".json", "_Groups_AfterContentMigration.csv") -NoTypeInformation -Force
            Write-Host "Created Lists and Groups Reports" -ForegroundColor Green
        }
        if(($Mode -eq "FullReport") -or ($Mode -eq "Permissions"))
        {
            $ValidationSummary | Where-Object {$_."Type of Entry" -eq "Group"} | Export-Csv -Path $SourceManifest.LocalPath.Replace(".json", "_Groups.csv") -NoTypeInformation -Force
            Write-Host "Created Groups Report" -ForegroundColor Green
        }
    }

}