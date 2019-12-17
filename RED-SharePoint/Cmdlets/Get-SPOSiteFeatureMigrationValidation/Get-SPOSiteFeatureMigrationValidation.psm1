function Get-SPOSiteFeatureMigrationValidation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$False, position=0)]
    [System.Collections.ArrayList]$SiteFeatureEntries,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
    )

    $SPOSiteURL = ($SiteFeatureEntries | Select-Object 'Destination Site URL' -Unique) | Select-Object -ExpandProperty 'Destination Site URL'
    $OnPremSiteURL = ($SiteFeatureEntries | Select-Object 'Source Site URL' -Unique) | select-object -ExpandProperty 'Source Site URL'
    try
    {
        try
        {
            Get-PnPConnection | Out-Null
            if(-not ((Get-PnPConnection).url.trimend("/") -eq $SPOSiteURL.trimend("/")))
            {
                Disconnect-PnPOnline
                Connect-PnPOnline -Url $SPOSiteURL.trimend("/") -Credentials $Credential | Out-Null
            }
        }
        catch
        {
            Connect-PnPOnline -Url $SPOSiteURL.trimend("/") -Credentials $Credential | Out-Null
        }
    }
    catch
    {
        write-host "Could not connect to web $($SPOSiteURL.trimend("/"))" -ForegroundColor Red
    }

    $SiteFeatureSummary = New-Object System.Collections.Arraylist
    
    $PNPSiteFeatures = Get-PnPFeature -Scope Site
    foreach($Feature in $SiteFeatureEntries)
    {
        $FeatureSummary = New-Object System.Object
        $FeatureSummary | Add-Member -MemberType NoteProperty -Name 'Type of Entry' -Value $Feature.'Type of Entry'
        $FeatureSummary | Add-Member -MemberType NoteProperty -Name 'Feature Name' -Value $Feature.'Feature Name'
        $FeatureSummary | Add-Member -MemberType NoteProperty -Name 'Feature ID' -Value $Feature.'Feature ID'
        $FeatureSummary | Add-Member -MemberType NoteProperty -Name 'Source Site URL' -Value $OnPremSiteURL
        $FeatureSummary | Add-Member -MemberType NoteProperty -Name 'Destination Site URL' -Value $SPOSiteURL
        if(($PNPSiteFeatures | Select-Object 'DefinitionID') -match $Feature.'Feature ID')
        {
            $FeatureSummary | add-member -MemberType NoteProperty -name 'SPOState' -Value "Activated"
        }
        else
        {
           $FeatureSummary | add-member -MemberType NoteProperty -name 'SPOState' -Value "Not Activated"
        }
        $SiteFeatureSummary.Add($FeatureSummary) | Out-Null
        Remove-Variable -Name FeatureSummary
    }
    foreach($Feature in $PNPSiteFeatures)
    {
        if(-not (($SiteFeatureEntries | select-object 'Feature ID') -match $Feature.DefinitionId))
        {
            $FeatureSummary = New-Object System.Object
            $FeatureSummary | Add-Member -MemberType NoteProperty -Name 'Type of Entry' -Value "Unexpected Site Feature"
            $FeatureSummary | Add-Member -MemberType NoteProperty -Name 'Feature Name' -Value $Feature.'DisplayName'
            $FeatureSummary | Add-Member -MemberType NoteProperty -Name 'Feature ID' -Value $Feature.'DefinitionID'
            $FeatureSummary | Add-Member -MemberType NoteProperty -Name 'Source Site URL' -Value $OnPremSiteURL
            $FeatureSummary | Add-Member -MemberType NoteProperty -Name 'Destination Site URL' -Value $SPOSiteURL
            $SiteFeatureSummary.Add($FeatureSummary) | Out-Null
            Remove-variable -name FeatureSummary
        }
    }
    Return $SiteFeatureSummary
}