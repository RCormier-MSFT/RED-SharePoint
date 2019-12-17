function Export-SPNavigationReport
{    
    param(
        [parameter(Mandatory=$True, position=0, HelpMessage="This output of this report will be a csv format")]
        [ValidateScript(
            {
                if($_.localpath.endswith("csv")){$True}else{throw "`r`n`'ReportFile`' must have a csv vile extension"}
            }
            )]
        [URI]$ReportFile,
        [Parameter(mandatory=$True, position=1, HelpMessage = "Which Navigational Elements Should Be Included In this Report?")]
        [ValidateSet("GlobalNavOnly", "QuickLaunchOnly", "GlobalNavAndQuickLaunch")]
        [String]$ReportNodes,
        [Parameter(Mandatory=$True, position=2, HelpMessage ="This is the input type of the report")]
        [ValidateSet("AllSites","InputFile", "SiteURL" )]
        [String]$InputType
    )
    DynamicParam
    {
        if ($InputType.ToLower() -eq "inputfile")
        {
            $InputFileAttribute = New-Object System.Management.Automation.ParameterAttribute
            $InputFileAttribute.HelpMessage = "Please specify the input CSV file:"
            $InputFileAttribute.Mandatory = $True
            $InputFileAttribute.Position = 3
            $InputFileAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $InputFileAttributeCollection.Add($InputFileAttribute)
            $InputFileParam = New-Object System.Management.Automation.RuntimeDefinedParameter('InputFile', [URI], $InputFileAttributeCollection)
            $paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('InputFile', $InputFileParam)
            return $paramDictionary
        }
        elseif ($InputType.ToLower() -eq "siteurl")
        {
            $SiteURLAttribute = New-Object System.Management.Automation.ParameterAttribute
            $SiteURLAttribute.HelpMessage = "Please specify the input CSV file:"
            $SiteURLAttribute.Mandatory = $True
            $SiteURLAttribute.Position = 3
            $SiteURLAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $SiteURLAttributeCollection.Add($SiteURLAttribute)
            $SiteURLParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SiteURL', [URI], $SiteURLAttributeCollection)
            $paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('SiteURL', $SiteURLParam)
            return $paramDictionary
        }
    }

    Begin
    {
        if($PSBoundParameters.InputFile)
        {
            if(-not (Test-Path $PSBoundParameters.inputfile.LocalPath))
            {
                Throw "File Not Found`r`n$($PSBoundParameters.InputFile.AbsolutePath)"
            }
            elseif(-not $PSBoundParameters.InputFile.LocalPath.tolower().endswith("csv"))
            {
                Throw "Parameter `'InputFile`' must have a csv extension"
                Break
            }
            else
            {
                [Array]$AllSites = Import-Csv -Path $PSBoundParameters.Inputfile.AbsolutePath
            }
        }
        elseif($PSBoundParameters.SiteURL)
        {
            [Array]$AllSites = get-spsite $PSBoundParameters.SiteURL.AbsoluteURI | select URL
            
        }
        else
        {
            [Array]$AllSites = Get-SPSite -limit All | select URL
        }

        if(Test-Path $ReportFile.LocalPath)
        {
            $ReportFile = "$($reportfile.LocalPath.Substring(0,$ReportFile.LocalPath.LastIndexOf(".")))-$(Get-Date -format MM-dd-yyyy_HH-MM-ss).csv"
        }

    }
    Process
    {
       
        foreach($Site in $AllSites)
       {
        $SiteSummary = Get-SPNavigationReport -SiteURL $Site.URL -ReportNodes $ReportNodes
        $SiteSummary | Export-Csv -Path $ReportFile.LocalPath -NoTypeInformation -Append
       }
    }
}
    