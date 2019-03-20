function New-SMATCheckedOutFileSummaryReportBulkCheckIn
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0)]
    [ValidateScript({if($_.localpath.endswith("csv")){$True}else{throw "`r`n`'InputFile`' must be a csv file"}})]
    [URI]$InputFile,
    [Parameter(mandatory=$False, position=1, HelpMessage="A site collection can optionally be specified, to process only a subset of a SMAT report")]
    [URI]$SiteURL,
    [Parameter(mandatory=$true, position=2, HelpMessage="This is the administrative message that will be recorded when the files are checked in")]
    [String]$AdminComment,
    [parameter(mandatory=$False, position=3, HelpMessage="This is the name of the output file")]
    [Validatescript({if($_.localpath.endswith(".csv")){$True}else{throw "`r`n`'OutputFile`' must be a csv file"}})]
    [URI]$OutputFile="SMATCheckInSummary.csv"
    )

    if(-not ($OutputFile.IsAbsoluteURI))
    {
        if(-not (Resolve-Path $OutputFile -ErrorAction SilentlyContinue))
        {
            $OutputFile = Join-Path (Get-Location | Select-Object -ExpandProperty path) $OutputFile.OriginalString
        }
    }

    $CheckedOutFiles = Import-Csv $InputFile.LocalPath
    $ThresholdColumn = $CheckedOutFiles | Get-Member | Where-Object {($_.membertype -eq "NoteProperty") -and ($_.name -like "Checked out More than*")} | Select-Object -ExpandProperty Name
    if($SiteURL)
    {
        [Array]$SitesToProcess = $SiteURL | Select-Object -ExpandProperty AbsoluteURI
    }
    else
    {
        [Array]$SitesToProcess = $CheckedOutFiles | Select-Object "SiteURL" -Unique | Select-Object -ExpandProperty SiteURL
    }
    $FileReport = New-Object System.Collections.ArrayList
    foreach($site in $SitesToProcess)
    {
        Write-Progress -Activity "Processing site $($SitesToProcess.IndexOf($Site)+1) of $($SitesToProcess.Count)" -Status "Processing site:  $($Site)" -PercentComplete (($SitesToProcess.IndexOf($Site)+1)/($SitesToProcess.count)*100) -Id 1
        $SPSite = Get-SPSite $Site
        foreach($File in ($CheckedOutFiles | Where-Object {($_.SiteURL -eq $Site) -and ($_."$($ThresholdColumn)" -eq "TRUE")}))
        {
            Write-Progress -Activity "Checking in File $($CheckedOutFiles.indexof($File)+1) of $($CheckedOutFiles.count)" -Status "Processing file $($File.'File URL')" -PercentComplete ((($CheckedOutFiles.IndexOf($File)+1)/$($CheckedOutFiles.Count)*100)) -ParentId 1
            $FileInformation = New-Object System.Object
            $FileInformation | Add-Member -MemberType NoteProperty -Name "File URL" -Value $File.'File URL'
            Try
            {
                $PossibleWebs = $SPSite.AllWebs | Where-Object {$File.'File URL'.StartsWith($_.URL)}
                foreach($Web in $PossibleWebs)
                {
                    $CurrentList = $web.Lists | Where-Object {$web.GetFile($File.'File URL').ServerRelativeURL.Startswith($_.RootFolder.ServerRelativeURL)}
                    if($CurrentList)
                    {
                        $error.Clear()
                        $Web.GetFile($File.'File URL'.Replace($web.url, "").substring(1)).Checkin($AdminMessage)
                    }
                }
                $FileInformation | Add-Member -MemberType NoteProperty -Name "Processed" -Value $True
            }
            Catch
            {
                $FileIsNotCheckedOut = $False
                foreach($ErrorEntry in $Error)
                {
                    $ExceptionMessage = $ErrorEntry.ExceptionMessage
                    if($ExceptionMessage.contains("is not checked out"))
                    {
                        $FileIsNotCheckedOut=$True
                    }
                }
                if($FileIsNotCheckedOut -eq $True)
                {
                    $FileInformation | Add-Member -MemberType NoteProperty -Name "Processed" -Value "File is not checked out"
                }
                else
                {
                    $FileInformation | Add-Member -MemberType NoteProperty -Name "Processed" -Value $False
                }

            }

            $FileReport.Add($FileInformation) | Out-Null
        }
        $SPSite.Dispose()
    }

    $FileReport | export-csv -Path ($OutputFile.LocalPath).Insert(($OutputFile.LocalPath.LastIndexOf(".")),"_$(Get-Date -Format MMddyy-hhmmss)")  -NoTypeInformation -Force

}