<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will produce a manifest of objects and properties that can be used to validate the success of a migration to Office 365
DependsOn: Get-SPWebMigrationManifestInfo, Get-SPListMigrationManifestInfo, Get-SiteMigrationManifestInfo, Get-SPWebRolesMigrationManifestInfo
#>

function New-SourceSiteMigrationManifest
{
    [cmdletbinding(SupportsShouldProcess=$True)]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This should be a CSV file that contains a Source URL and a Destination URL for all site collections included in this manifest")]
    [ValidateScript({
        if($_.localpath.endswith("csv")){$True}else{throw "`r`n`'InputFile`' must be a csv file"}
        if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
    })]
    [URI]$InputFile,
    [parameter(Mandatory=$False, position=1, HelpMessage="Use the -AppDomainNamespaceExclusionFile parameter to specify a text file containing a list of app domain namespaces that should be escluded.")]
    [ValidateScript({
        if($_.localpath.endswith("txt")){$True}else{throw "`r`n`'InputFile`' must be a txt file"}
        if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
    })]
    [URI]$AppDomainNamespaceExclusionFile,
    [parameter(Mandatory=$False, position=2, HelpMessage="Use the -GroupExclusionFile parameter to specify a text file containing a list groups that should be evaluated for exclusion.")]
    [ValidateScript({
        if($_.localpath.endswith("txt")){$True}else{throw "`r`n`'InputFile`' must be a txt file"}
        if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
    })]
    [URI]$GroupExclusionFile,
    [parameter(Mandatory=$False, position=3, HelpMessage="Use the -Force switch to overwrite the existing output file")]
    [switch]$Force,
    [parameter(Mandatory=$False, position=4, HelpMessage="Use the -IncludeHiddenLists switch to include hidden lists in the report")]
    [switch]$IncludeHidddenLists
    )
    DynamicParam
    {
        $ParameterName = 'OutputFile'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $ParameterAttribute.Position = 1
        $AttributeCollection.Add($ParameterAttribute)
        $ValidateScriptAttribute = New-Object System.Management.Automation.ValidateScriptAttribute({
            if($_.localpath.endswith("json")){$True}else{throw "`r`n`'OutputFile`' must be a JSON file"}
            if(!(Test-Path $_.localpath)){$True}elseif((Test-Path $_.localpath) -and ($Force)){$True}else{throw "`r`nFile $($_.localpath) already exists.  Use the -Force switch"}
        })
        $AttributeCollection.Add($ValidateScriptAttribute)

        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [URI], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary

    }
    begin
    {
        $AllParameters = $PSBoundParameters
        if([string]::IsNullOrEmpty($AllParameters["OutputFile"].localpath))
        {
            [URI]$AllParameters["OutputFile"] = $InputFile.LocalPath.Replace(".csv",".json")
        }
        [URI]$AllParameters["OutputFile"] = $AllParameters["OutputFile"].localpath.Replace(".json", "_$(Get-Date -Format MMddyyyy-HH_mm_ss).json")
    }
    Process
    {
        $SitesList = Import-Csv -Path $InputFile.LocalPath | Where-Object {$_."Source Site URL".length -gt 0}
        $ReportInformation = New-Object System.Collections.Arraylist
        foreach($Site in $SitesList)
        {

            $SPSite = Get-SPSite $Site."Source Site URL".Trimend("/")
            $SiteEntry = Get-SPSiteMigrationManifestInfo $SPSite
            $SiteEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SPSite."URL"
            $SiteEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -value $Site."Destination Site URL"
            if($AppDomainNameSpaceExclusionFile)
            {
                [Array]$Exclusions = Get-Content $AppDomainNameSpaceExclusionFile.LocalPath
                $ExcludedWebs = New-Object System.Collections.Arraylist
                $WebsToProcess = New-Object System.Collections.ArrayList
                foreach($Exclusion in $Exclusions)
                {
                    [Array]$ExclusionMatches = $SPSite.AllWebs | ? {$_.url -match $Exclusion}
                    if($ExclusionMatches)
                    {
                        foreach($Match in $ExclusionMatches)
                        {
                            $ExcludedWebs.Add($Match.url) | Out-Null
                        }
                    }
                }
                foreach($Web in $SPSite.AllWebs)
                {
                    if($ExcludedWebs -match $Web.url)
                    {
                        Write-Verbose "Web `'$($Web.url)`' has been excluded"
                    }
                    else
                    {
                        $WebsToProcess.Add($Web) | Out-Null
                    }
                }
                $SiteEntry.'Number of webs' = $WebsToProcess.Count
            }
            else
            {
                $WebsToProcess = $SPSite.AllWebs
                $SiteEntry.'Number of webs' = $WebsToProcess.Count
            }
            $ReportInformation.Add($SiteEntry) | Out-Null
            $SiteFeatures = Get-SPFeature -Site $SPSite
            foreach($SPFeature in $SiteFeatures)
            {
                $SiteFeatureEntry  = Get-SPSiteFeatureMigrationManifestInfo $SPFeature
                $SiteFeatureEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SPSite."URL"
                $SiteFeatureEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -value $Site."Destination Site URL"
                $ReportInformation.add($SiteFeatureEntry) | Out-Null
            }
            foreach ($Web in $WebsToProcess)
            {
                if($IncludeHidddenLists)
                {
                    $WebEntry = Get-SPWebMigrationManifestInfo $Web -IncludeHiddenLists
                }
                else
                {
                    $WebEntry = Get-SPWebmigrationManifestInfo $Web
                }

                $WebEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SiteEntry."Source Site URL"
                $WebEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $SiteEntry."Destination Site URL"
                $ReportInformation.Add($WebEntry) | Out-Null
                if($WebEntry.'Has Unique Permissions' -eq "True")
                {
                    if($Web.IsRootWeb)
                    {
                        $WebRolesEntries = Get-SPWebRolesMigrationManifestInfo -SPWeb $Web
                        foreach($WebRole in $WebRolesEntries)
                        {
                            $WebRole | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SiteEntry."Source Site URL"
                            $WebRole | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $SiteEntry."Destination Site URL"
                            $ReportInformation.Add($WebRole) | Out-Null
                        }
                    }
                    if($GroupExclusionFile)
                    {
                        $WebGroupEntries = Get-SPWebGroupsMigrationManifestInfo -SPWeb $Web -GroupExclusionFile $GroupExclusionFile
                    }
                    else
                    {
                        $WebGroupEntries = Get-SPWebGroupsMigrationManifestInfo -SPWeb $Web
                    }
                    foreach($WebGroup in $WebGroupEntries)
                    {
                        $WebGroup | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SiteEntry."Source Site URL"
                        $WebGroup | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $SiteEntry."Destination Site URL"
                        $ReportInformation.Add($WebGroup) | Out-Null
                    }
                    $AllGroups = $web.SiteGroups
                    foreach($Group in $AllGroups)
                    {
                        $GroupEntry = New-Object System.Object
                        $GroupEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Group Mapping"
                        $GroupEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SiteEntry."Source Site URL"
                        $GroupEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $SiteEntry."Destination Site URL"
                        $GroupEntry | add-Member -MemberType NoteProperty -Name "Web URL" -Value $web.URL
                        $GroupEntry | Add-Member -MemberType NoteProperty -Name "Group Name" -Value $Group.Name
                        if($Group.Roles.count -gt 0)
                        {
                            $GroupEntry | Add-Member -MemberType NoteProperty -Name "Roles Assigned" -Value ([String]::Join(",", ($Group.Roles | Select-Object -ExpandProperty Name)))
                        }
                        else
                        {
                            $GroupEntry | Add-Member -MemberType NoteProperty -Name "Roles Assigned" -Value "None"
                        }
                        $ReportInformation.Add($GroupEntry) | Out-Null
                    }

                }
                if($IncludeHidddenLists)
                {
                    foreach($list in $web.lists)
                    {
                        $ListEntry = Get-SPListMigrationManifestInfo $list
                        $ListEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SiteEntry."Source Site URL"
                        $ListEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $SiteEntry."Destination Site URL"
                        $ListEntry | Add-Member -MemberType NoteProperty -Name "Web URL" -value $WebEntry."Web URL"
                        $ReportInformation.Add($ListEntry) | Out-Null
                    }
                }
                else
                {
                    foreach($list in $web.lists | Where-Object {-not $_.hidden})
                    {
                        $ListEntry = Get-SPListMigrationManifestInfo $list
                        $ListEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SiteEntry."Source Site URL"
                        $ListEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $SiteEntry."Destination Site URL"
                        $ListEntry | Add-Member -MemberType NoteProperty -Name "Web URL" -value $WebEntry."Web URL"
                        $ReportInformation.Add($ListEntry) | Out-Null
                    }
                }
            }

        }
    }
    end
    {
            $ReportInformation | ConvertTo-Json | out-file $AllParameters["OutputFile"].localpath -Force
            write-host "Source Site Migration Manifest created at: $($AllParameters["OutputFile"].localpath)" -ForegroundColor Green
    }
}
