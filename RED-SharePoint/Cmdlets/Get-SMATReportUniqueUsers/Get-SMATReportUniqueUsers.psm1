<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will parse through a SMAT Checked Out Files report (in csv) and return the unique users
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


