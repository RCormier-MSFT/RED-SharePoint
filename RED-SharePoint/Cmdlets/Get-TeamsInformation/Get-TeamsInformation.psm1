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
    $AdminCredentials = (Get-Credential -Message "Please enter the credentials of an Exchange Online administrator")
    #Detect if proxy is enabled
    $SettingsPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"
    if(Get-ItemProperty -Path $SettingsPath -Name AutoConfigURL -ErrorAction SilentlyContinue)
    {
        $PSSessionOptions = New-PSSessionOption -ProxyAccessType IEConfig
        $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $AdminCredentials -Authentication Basic -AllowRedirection -SessionOption $PSSessionOptions
    }
    else
    {
        $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $AdminCredentials -Authentication Basic -AllowRedirection
    }
    Import-PSSession $EXOSession -AllowClobber
    $UnifiedGroups = Get-UnifiedGroup -IncludeSoftDeletedGroups
    $GroupCollection = New-Object System.Collections.Arraylist
    foreach($UnifiedGroup in $UnifiedGroups)
    {
        $ThisGroup = New-Object System.Object
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "Name" -Value "$($UnifiedGroup.DisplayName)"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "URL" -Value "$($UnifiedGroup.SharePointSiteURL)"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "Owner(s)" -Value "$((Get-UnifiedGroupLinks -Identity $UnifiedGroup.DisplayName -LinkType "Owners" | select-object -ExpandProperty DisplayName) -join ",")"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "OwnerEmail(s)" -Value "$((Get-UnifiedGroupLinks -identity $UnifiedGroup.DisplayName -LinkType "Owners" | select-object -ExpandProperty PrimarySMTPAddress) -join ",")"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "Total Members" -Value "$((Get-UnifiedGroupLinks -identity $UnifiedGroup.DisplayName -LinkType "Members" | select-object -ExpandProperty Name).count)"
        $ThisGroup | Add-Member -MemberType NoteProperty -Name "CreationDate (UTC)" -Value "$($UnifiedGroup.WhenCreatedUTC)"
        if($UnifiedGroup.ProvisioningOption -eq "YammerProvisioning")
        {
            $ThisGroup | Add-Member -MemberType NoteProperty -Name "ProvisioningOption" -Value "Yammer"
        }
        elseif(($UnifiedGroup.ProvisioningOption -eq "ExchangeProvisioningFlags:3552") -or ($UnifiedGroup.ProvisioningOption -eq "ExchangeProvisioningFlags:481"))
        {
            $ThisGroup | Add-Member -MemberType NoteProperty -Name "ProvisioningOption" -Value "Teams"
        }
        else
        {
            $ThisGroup | Add-Member -MemberType NoteProperty -Name "ProvisioningOption" -Value $UnifiedGroup.ProvisioningOption
        }
        $GroupCollection.Add($ThisGroup) | Out-Null
    }
    $GroupCollection | Export-Csv -Path $OutputFile.AbsolutePath -Force -NoTypeInformation
    Get-PSSession | Remove-PSSession
}
