<#
.SYNOPSIS

This cmdlet compares features across two site collections, or two webs

.DESCRIPTION

The Compare-SPFeatures (RED-SharePoint) cmdlet allows you the differences with features between two sites of two webs.


.PARAMETER SourceSiteCollection

Specifies the URL of the SharePoint source Site Collection.

.PARAMETER TargetSiteCollection

Specifies the URL of the SharePoint target Site Collection.

.PARAMETER SourceWeb

Specifies the URL of the SharePoint source web.

.PARAMETER TargetWeb

Specifies the URL of the SharePoint target web.


.EXAMPLE 

Compare-SPFeatures -SourceSiteCollection https://example.sharpoint.com/sites/src01 -TargetSiteCollection https://example.sharepoint.com/sites/tgt01

.EXAMPLE 

Compare-SPFeatures -SourceWeb https://example.sharpoint.com/sites/src01/web1 -TargetWeb https://example.sharepoint.com/sites/tgt01/web3


.NOTES

Author:     Roger Cormier
Company:    Microsoft

#>

function Compare-SPFeatures
{
    [cmdletbinding()]
    param(
    [Parameter(Mandatory=$true, Position=0, ParameterSetName="SPSite")]
    [URI]$SourceSiteCollection,
    [Parameter(Mandatory=$true, Position=1, ParameterSetName="SPSite")]
    [URI]$TargetSiteCollection,
    [Parameter(Mandatory=$true, Position=0, ParameterSetName="SPWeb")]
    [URI]$SourceWeb,
    [Parameter(Mandatory=$true, Position=1, ParameterSetName="SPWeb")]
    [URI]$TargetWeb
    )

    if($PSCmdlet.ParameterSetName -eq "SPSite")
    {
        Write-Verbose "Site Collection Feature Comparison"
        $SourceFeatures = Get-SPFeature -Site $SourceSiteCollection.AbsoluteUri
        $TargetFeatures = Get-SPFeature -Site $TargetSiteCollection.AbsoluteUri
    }
    elseif($PSCmdlet.ParameterSetName -eq "SPWeb")
    {
        Write-Verbose "Site Feature Comparison"
        $SourceFeatures = Get-SPFeature -Web $SourceWeb.AbsoluteUri
        $TargetFeatures = Get-SPFeature -Web $TargetWeb.AbsoluteUri
    }
    $MismatchedFeatures = New-Object System.Collections.Arraylist
    foreach($Feature in $SourceFeatures)
    {
        if(!($TargetFeatures -imatch $Feature))
        {
           $FeatureEntry = New-Object System.Object
           $FeatureEntry | Add-Member -MemberType NoteProperty -Name "Feature Name" -Value $feature.DisplayName
           $FeatureEntry | Add-Member -MemberType NoteProperty -Name "Activated In" -Value "Source Only"
           $MismatchedFeatures.Add($FeatureEntry) | Out-Null
        }
    }
    foreach($feature in $TargetFeatures)
    {
        if(!($SourceFeatures -imatch $Feature))
        {
           $FeatureEntry = New-Object System.Object
           $FeatureEntry | Add-Member -MemberType NoteProperty -Name "Feature Name" -Value $feature.DisplayName
           $FeatureEntry | Add-Member -MemberType NoteProperty -Name "Activated In" -Value "Target Only"
           $MismatchedFeatures.Add($FeatureEntry) | Out-Null
        }
    }
    Return $MismatchedFeatures
}