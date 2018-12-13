<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will return inforamtion about an SPWeb that will be important in determining the success level of a migration to SharePoint Online
#>

function Get-SPWebMigrationManifestInfo
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This parameter requires an SPWeb object to be passed", ValueFromPipeline=$True, ValueFromPipelineByPropertyName)]
    [Alias('URL')]
    [Microsoft.SharePoint.SPWeb]$SPWeb,
    [parameter(Mandatory=$False, position=1, HelpMessage="Use the -IncludeHiddenLists switch to include hidden lists in the report")]
    [switch]$IncludeHidddenLists
    )

    $WebEntry = New-Object System.Object
    $WebEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Web"
    $WebEntry | Add-Member -MemberType NoteProperty -Name "Web Title" -Value $SPWeb.Title
    $WebEntry | Add-Member -MemberType NoteProperty -Name "Web URL" -Value $SPWeb.Url
    $WebEntry | Add-Member -MemberType NoteProperty -Name "Has Unique Permissions" -Value $SPWeb.HasUniquePerm
    if($IncludeHidddenLists)
    {
        $WebEntry | Add-Member -MemberType NoteProperty -Name "Number of Lists" -Value $SPWeb.lists.Count
    }
    else
    {
        $WebEntry | Add-Member -MemberType NoteProperty -Name "Number of Lists" -Value ($SPWeb.lists | Where-Object {-not $_.hidden}).Count
    }
    $WebEntry | Add-Member -MemberType NoteProperty -Name "Workflow Associations" -Value $SPWeb.WorkflowAssociations.count
    if($SPWeb.RootFolder.WelcomePage)
    {
        $WebEntry | Add-Member -MemberType NoteProperty -Name "Web Parts on Page" -value ($SPWeb.GetFile($SPWeb.RootFolder.WelcomePage).GetLimitedWebPartManager([System.Web.UI.WebControls.Webparts.PersonalizationScope]::Shared).webparts.count)
        $WebEntry | Add-Member -MemberType NoteProperty -Name "Visible Web Parts on Page" -value (($SPWeb.GetFile($SPWeb.RootFolder.WelcomePage).GetLimitedWebPartManager([System.Web.UI.WebControls.Webparts.PersonalizationScope]::Shared).webparts | Where-Object {$_.IsClosed -eq $False}).count)
    }
    else
    {
        $WebEntry | Add-Member -MemberType NoteProperty -Name "Web Parts on Page" -Value "Error retrieving welcome page"
        $WebEntry | Add-Member -MemberType NoteProperty -Name "Visible Web Parts on Page" -Value "Error retrieving welcome page"
    }


    Return $WebEntry
}
