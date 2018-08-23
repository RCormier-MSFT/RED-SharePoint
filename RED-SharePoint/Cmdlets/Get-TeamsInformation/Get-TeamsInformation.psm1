<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will produce a report detailing information regarding Teams
#>
function Get-TeamsInformation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This parameter represents the output file you wish to produce")]
    [URI]$OutputFile,
    [parameter(Mandatory=$True, position=1, HelpMessage="This parameter represents the admin URL of your SharePoint Online service")]
    [URI]$SPOAdminURL
    )
    $AdminCredentials = (Get-Credential -Message "Please enter the credentials of a user who is both a SharePoint Online administrator and an Exchange Online administrator")
    Connect-SPOService -Url $SPOAdminURL -Credential $AdminCredentials
    $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $AdminCredentials -Authentication Basic -AllowRedirection
    Import-PSSession $EXOSession -AllowClobber
    $Groups = Get-SPOSite -Template "Group#0" -Limit all
    $GroupCollection = New-Object System.Collections.Arraylist
    foreach($Group in $Groups)
    {
        $UnifiedGroup = get-unifiedgroup $Group.title
        $ThisGroup = New-Object System.Object
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "Name" -Value "$($Group.Title)"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "URL" -Value "$($Group.URL)"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "Owner(s)" -Value "$((Get-UnifiedGroupLinks -Identity $UnifiedGroup.DisplayName -LinkType "Owners" | select-object -ExpandProperty DisplayName) -join ",")"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "OwnerEmail(s)" -Value "$((Get-UnifiedGroupLinks -identity $UnifiedGroup.DisplayName -LinkType "Owners" | select-object -ExpandProperty PrimarySMTPAddress) -join ",")"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "Total Members" -Value "$((Get-UnifiedGroupLinks -identity $UnifiedGroup.DisplayName -LinkType "Members" | select-object -ExpandProperty Name).count)"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "CreationDate (UTC)" -Value "$($UnifiedGroup.WhenCreatedUTC)"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "SharePointSiteURL" -Value "$($UnifiedGroup.SharePointSiteURL)"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "O365Group" -Value "$($UnifiedGroup.Alias)"
        $GroupCollection.Add($ThisGroup) | Out-Null
    }
    $GroupCollection | Export-Csv -Path $OutputFile.AbsolutePath -Force -NoTypeInformation
    Get-PSSession | Remove-PSSession
}
