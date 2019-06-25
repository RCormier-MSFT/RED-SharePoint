<#
.SYNOPSIS
This cmdlet will parse through a SMAT Checked Out Files report (in csv) and Return the unique sites

.DESCRIPTION

The Get-SMATReportUniqueSites (RED-SharePoint) cmdlet takes a SharePoint Migration Assessment Tool (SMAT) Report csv file and returns a list of unique sites

.PARAMETER InputFile

Takes the full path to the SMAT report csv file

.EXAMPLE 

Get-SMATReportUniqueSites "C:\Support\Reports\SMATReportOne.csv" 

.NOTES
Author: Roger Cormier
Company: Microsoft
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