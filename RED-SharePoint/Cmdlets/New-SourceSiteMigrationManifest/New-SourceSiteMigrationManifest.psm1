<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will produce a manifest of objects and properties that can be used to validate the success of a migration to Office 365
DependsOn: Get-WebManifest, Get-ListManifest, Get-SiteManifest
#>

function New-SourceMigrationManifest
{
    [cmdletbinding(SupportsShouldProcess=$True)]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This should be a CSV file that contains a Source URL and a Destination URL for all site collections included in this manifest")]
    [ValidateScript({
        if($_.localpath.endswith("csv")){$True}else{throw "`r`n`'InputFile`' must be a csv file"}
        if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
    })]
    [URI]$InputFile,
    [parameter(Mandatory=$False, position=1, HelpMessage="Use the -Force switch to overwrite the existing output file")]
    [switch]$Force
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
    }
    Process
    {
        $SitesList = Import-Csv -Path $InputFile.LocalPath
        $ReportInformation = New-Object System.Collections.Arraylist
        foreach($Site in $SitesList)
        {

            $SPSite = Get-SPSite $Site."Source Site URL"
            $SiteEntry = Get-SPSiteMigrationManifestInfo $SPSite
            $SiteEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SPite."Source Site URL"
            $SiteEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -value $Site."Destination Site URL"
            $ReportInformation.Add($SiteEntry) | Out-Null
            foreach ($Web in $SPSite.AllWebs)
            {
                $WebEntry = Get-SPWebMigrationManifestInfo $Web
                $WebEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SiteEntry."Source Site URL"
                $ReportInformation.Add($WebEntry) | Out-Null
                foreach($list in $web.lists)
                {
                    $ListEntry = Get-SPListMigrationManifestInfo $list
                    $ListEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $SiteEntry."Source Site URL"
                    $ListEntry | Add-Member -MemberType NoteProperty -Name "Web URL" -value $WebEntry."Web URL"
                    $ReportInformation.Add($ListEntry) | Out-Null
                }
            }

        }
    }
    end
    {
            $ReportInformation | ConvertTo-Json | out-file $AllParameters["OutputFile"].localpath -Force
    }
}
