<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will return inforamtion about an SPSite that will be important in determining the success level of a migration to SharePoint Online
#>
function Get-SPSiteMigrationManifestInfo
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This parameter requires an SPWeb object to be passed", ValueFromPipeline=$True, ValueFromPipelineByPropertyName)]
    [Alias('URL')]
    [Microsoft.SharePoint.SPSite]$SPSite
    )

    $SiteEntry = New-Object System.Object
    $SiteEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -value "Site Collection"
    $SiteEntry | Add-Member -MemberType NoteProperty -Name "Number of Webs" -Value $SPSite.AllWebs.Count
    Return $SiteEntry

}