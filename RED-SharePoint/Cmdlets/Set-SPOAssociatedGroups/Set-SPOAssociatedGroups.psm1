<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet can be used to set the associated visitors, members, or owners groups for a SharePoint Online site
#>

function Set-SPOAssociatedGroups
{
    [cmdletbinding()]
    param(
        [parameter(mandatory=$True, position=0, HelpMessage="Specify the URL of the SharePoint Online Site" )]
        [URI]$SiteURI,
        [parameter(Mandatory=$True, position=1)]
        [System.Management.Automation.PSCredential]$Credential,
        [parameter(mandatory=$False, position=2, HelpMessage="Speify the name of the associated visitor group for the site")]
        [String]$AssociatedVisitorGroup,
        [parameter(mandatory=$False, position=3, HelpMessage="Speify the name of the associated member group for the site")]
        [String]$AssociatedMemberGroup,
        [parameter(mandatory=$False, position=4, HelpMessage="Speify the name of the associated owner group for the site")]
        [String]$AssociatedOwnerGroup
    )

    Connect-PnPOnline -Url $SiteURI.AbsoluteUri -Credentials $Credential
    if(-not [String]::IsNullOrEmpty($AssociatedVisitorGroup))
    {
        Set-PnPGroup -Identity (Get-PnPGroup $AssociatedVisitorGroup).ID -SetAssociatedGroup Visitors
    }
    if(-not [String]::IsNullOrEmpty($AssociatedMemberGroup))
    {
        Set-PnPGroup -Identity (Get-PnPGroup $AssociatedMemberGroup).ID -SetAssociatedGroup Members
    }
    if(-not [String]::IsNullOrEmpty($AssociatedOwnerGroup))
    {
        Set-PnPGroup -Identity (Get-PnPGroup $AssociatedOwnerGroup).ID -SetAssociatedGroup Owners
    }
}