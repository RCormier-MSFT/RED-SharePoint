<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will parse through a SMAT Checked Out Files report (in csv) and return how long it has been since each file was checked out
#>

function New-SMATReportCheckedOutFilesSummary
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0)]
    [ValidateScript({if($_.localpath.endswith("csv")){$True}else{throw "`r`n`'InputFile`' must be a csv file"}})]
    [URI]$InputFile,
    [parameter(mandatory=$False, position=1, HelpMessage="This is the name of the output file")]
    [Validatescript({if($_.localpath.endswith(".csv")){$True}else{throw "`r`n`'OutputFile`' must be a csv file"}})]
    [URI]$OutputFile=".\SMATCheckedOutFileReport.csv",
    [Parameter(mandatory=$False, position=2, HelpMessage="A site collection can optionally be specified, to process only a subset of a SMAT report")]
    [String]$SiteURL,
    [Parameter(mandatory=$False, position=3, HelpMessage="Specify a threshold, in days, to use as an indicator in the summary report.  Default value is 60 days")]
    [Int32]$ReportThresholdInDays=60,
    [Parameter(mandatory=$False, position=4, HelpMessage="Use this switch to overwrite existing SMAT checked out file report")]
    [switch]$Force
    )
    $OutputFile = Get-URIFromString $OutputFile.OriginalString
    if((Test-Path $($OutputFile.LocalPath)) -and (!$Force))
    {
        Write-Error "`r`nOutputFile `'$($OutputFile.LocalPath)`' already exists.  Specify a new path or use the `'-Force`' switch to overwrite the file"
        exit
    }
    else
    {
        $AllItems = Import-Csv $InputFile.LocalPath
        if($SiteURL)
        {
            [Array]$AllSites = $SiteURL
        }
        else
        {
            [Array]$AllSites = Get-SMATReportUniqueSites -InputFile $InputFile.LocalPath
        }
        $FileReport = New-Object System.Collections.ArrayList
        foreach($Site in $AllSites)
        {
            $SPSite = get-spsite $Site
           [Array]$Files = $AllItems | Where-Object {$_.SiteURL -eq $Site}
            ForEach($File in $Files)
            {
                [DateTime]$CheckOutDate = $SPSite.rootweb.getfile($File.File).checkedoutdate
                $FileInformation = New-Object System.Object
                $FileInformation | Add-Member -MemberType NoteProperty -Name "SiteURL" -Value $File.SiteURL
                $FileInformation | Add-Member -MemberType NoteProperty -Name "File URL" -Value $File.File
                $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out To" -Value $File.CheckedOutUser
                $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Date" -Value $CheckOutDate
                $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Days" -value $((Get-Date).Subtract($CheckOutDate).Days)
                if((get-date).Subtract($CheckOutDate).days -gt 60)
                {
                    $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "True"
                }
                else
                {
                    $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "False"
                }
                $FileReport.Add($FileInformation) | Out-Null
            }
            $SPSite.Dispose()
        }

        if(!(Test-Path $OutputFile.LocalPath.Substring(0,$OutputFile.LocalPath.LastIndexOf("\"))))
        {
            New-Item -Path $OutputFile.LocalPath.Substring(0,$OutputFile.LocalPath.LastIndexOf("\")) -ItemType Directory
        }
    }
    $FileReport | Export-Csv -Path $OutputFile.LocalPath -NoTypeInformation -Force
}
