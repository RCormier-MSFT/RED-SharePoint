<#
Author: Roger Cormier
Company: Microsoft
Description: This cmdlet compares features across two site collections, or two webs
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