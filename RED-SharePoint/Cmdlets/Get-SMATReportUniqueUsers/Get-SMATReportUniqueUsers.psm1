<#
.SYNOPSIS

This cmdlet will parse through a SMAT Checked Out Files report (in csv) and return the unique users

.DESCRIPTION

The Get-SMATReportUniqueUsers (RED-SharePoint) cmdlet takes a SharePoint Migration Assessment Tool (SMAT) Report csv file and returns a list of unique sites

.PARAMETER InputFile

Takes the full path to the SMAT report csv file

.EXAMPLE 

Get-SMATReportUniqueUsers "C:\Support\Reports\SMATReportOne.csv" 

.NOTES
Author: Roger Cormier
Company: Microsoft
#>

function Get-SMATReportUniqueUsers
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0)]
    [ValidateScript({if($_.localpath.endswith("csv")){$True}else{throw "`r`n`'InputFile`' must be a csv file"}})]
    [URI]$InputFile
    )

    $CheckedOutFiles = Import-Csv $InputFile.LocalPath
    [Array]$UniqueUsers = $CheckedOutFiles | Sort-Object CheckedOutUser -Unique | select-object -ExpandProperty CheckedOutUser
    Return $UniqueUsers
}


