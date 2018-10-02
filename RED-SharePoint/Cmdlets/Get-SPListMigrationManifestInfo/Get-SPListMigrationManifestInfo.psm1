<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will return inforamtion about an SPList that will be important in determining the success level of a migration to SharePoint Online
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