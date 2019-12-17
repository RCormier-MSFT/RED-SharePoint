function Get-SPSiteFeatureMigrationManifestInfo
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This parameter requires an SPFeature object to be passed", ValueFromPipeline=$True, ValueFromPipelineByPropertyName)]
    [Alias('URL')]
    [Microsoft.SharePoint.Administration.SPFeatureDefinition]$SPFeature
    )

    $SiteFeatureEntry = New-Object System.Object
    $SiteFeatureEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -value "Site Collection Feature"
    $SiteFeatureEntry | Add-Member -MemberType NoteProperty -Name "Feature Name" -Value $SPFeature.DisplayName
    $SiteFeatureEntry | Add-Member -MemberType NoteProperty -Name "Feature ID" -Value $SPFeature.ID
    Return $SiteFeatureEntry

}