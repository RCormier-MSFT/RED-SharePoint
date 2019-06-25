<#
.SYNOPSIS

This cmdlet will return information about an SPList that will be important in determining the success level of a migration to SharePoint Online

.DESCRIPTION

The Get-SPListMigrationManifestInfo (RED-SharePoint) cmdlet takes a SharePoint list of type Document Library and returns a list of checked out files.

.PARAMETER InputFile

Takes the full path to the SMAT report csv file

.EXAMPLE 

Get-SMATReportUniqueUsers "C:\Support\Reports\SMATReportOne.csv" 

.NOTES
Author: Roger Cormier
Company: Microsoft
#>
function Get-SPListMigrationManifestInfo
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This parameter requires an SPWeb object to be passed", ValueFromPipeline=$True, ValueFromPipelineByPropertyName)]
    [Alias('Title')]
    [Microsoft.SharePoint.SPList]$SPList
    )

    $ListEntry = New-Object System.Object
    $ListEntry | Add-Member -MemberType NoteProperty -name "Type of Entry" -Value "List"
    $ListEntry | Add-Member -MemberType NoteProperty -Name "List Title" -Value $SPList.Title
    $ListEntry | Add-Member -MemberType NoteProperty -name "Number of Items" -Value $SPList.ItemCount
    $ListEntry | Add-Member -MemberType NoteProperty -Name "Workflows Associated" -value $SPlist.WorkflowAssociations.count
    Return $ListEntry
}