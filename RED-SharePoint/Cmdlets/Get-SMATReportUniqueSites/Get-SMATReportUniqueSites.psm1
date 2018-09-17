<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will parse through a SMAT Checked Out Files report (in csv) and Return the uniques sites
#>

function Get-SMATReportUniqueSites
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="Provide a SMAT checked out files report for this parameter")]
    [ValidateScript({if($_.localpath.endswith("csv")){$True}else{throw "`r`n`'InputFile`' must be a csv file"}})]
    [URI]$InputFile
    )

    $CheckedOutFiles = Import-Csv $InputFile.LocalPath
    [Array]$UniqueSites = $CheckedOutFiles |Sort-Object -Unique SiteURL | Select-Object -ExpandProperty SiteURL
    return $UniqueSites
}