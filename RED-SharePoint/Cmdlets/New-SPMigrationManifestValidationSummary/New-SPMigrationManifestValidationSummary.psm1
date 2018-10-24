function New-SPMigrationManifestValidationSummary
{
    [cmdletbinding(SupportsShouldProcess=$True)]
    param(
    [parameter(Mandatory=$True, position=0, HelpMessage="This should be a JSON file that was generated using New-SourceMigrationManifest")]
    [ValidateScript({
        if($_.localpath.endswith("json")){$True}else{throw "`r`n`'InputFile`' must be a JSON file"}
        if(test-path $_.localpath){$True}else{throw "`r`nFile $($_.localpath) does not exist"}
    })]
    [URI]$SourceManifest,
    [parameter(Mandatory=$False, position=1, HelpMessage="This is the output CSV file that will be generated bu this script")]
    [ValidateScript({
        if($_.localpath.endswith("json")){$True}else{throw "`r`n`'InputFile`' must be a JSON file"}
        if(!(Test-Path $_.localpath)){$True}elseif((Test-Path $_.localpath) -and ($Force)){$True}else{throw "`r`nFile $($_.localpath) already exists.  Use the -Force switch"}
    })]
    [URI]$OutputFile,
    [parameter(Mandatory=$True, position=2, HelpMessage="Used to indicate which phase of reporting we are performing")]
    [ValidateSet("Structure", "ItemCount", "Permissions")]
    [String]$Mode,
    [parameter(Mandatory=$False, position=2, HelpMessage="Supply a credential object to connect to SharePOint Online")]
    [System.Management.Automation.PSCredential]$Credential,
    [parameter(Mandatory=$False, position=3, HelpMessage="Use the -Force switch to overwrite the existing output file")]
    [switch]$Force
    )

    if([String]::IsNullOrEmpty($OutputFile.LocalPath))
    {
        $OutputDirectory = New-Object Uri($SourceManifest, ".")
        $OutputFile = Join-Path $OutputDirectory.LocalPath "\ValidationSummary.json"
    }

    $SourceEntries = (Get-Content $SourceManifest.LocalPath | ConvertFrom-Json)
    $UniqueSites = , $SourceEntries | Get-UniqueSitesFromSourceSiteMigrationManifest
    $ValidationSummary = New-Object System.Collections.Arraylist
    foreach($Site in $UniqueSites)
    {
        $RelevantEntries = $SourceEntries | where-object {$_."Source Site URL" -eq $Site."Source Site URL"}
        foreach($Entry in $RelevantEntries)
        {
            if($Entry.'Type of Entry' -eq "Site Collection")
            {
                if(($Mode -eq "Structure") -or ($Mode -eq "ItemCount"))
                {
                    $SummaryInfo =  $Entry | Get-SPSiteMigrationValidation -Credential $Credential
                    if($SummaryInfo)
                    {
                        $ValidationSummary.Add($SummaryInfo) | Out-Null
                    }
                    else
                    {
                        $ErrorObject = New-Object System.Object
                        $ErrorObject | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Site"
                        $ErrorObject | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $entry.'Destination Site URL'
                        $ErrorObject | Add-Member -MemberType NoteProperty -Name "Error" -Value "Error Processing Site $($Entry.'Destination Site URL')"
                        $ValidationSummary.Add($ErrorObject) |Out-Null
                    }
                    Remove-Variable -Name SummaryInfo
                }

            }
            elseif($Entry.'Type of Entry' -eq "Web")
            {
                if(($Mode -eq "Structure") -or ($Mode -eq "ItemCount"))
                {
                    $SummaryInfo = $Entry | Get-SPWebMigrationValidation -Credential $Credential
                    if($SummaryInfo)
                    {
                        $ValidationSummary.Add($SummaryInfo) | Out-Null
                    }
                    else
                    {
                        $ErrorObject = New-Object System.Object
                        $ErrorObject | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Web"
                        $ErrorObject | Add-Member -MemberType NoteProperty -name "Destination Web URL" -Value $(($Entry.'Web URL').Replace($Entry.'Source Site URL', $Entry.'Destination Site URL'))
                        $ErrorObject | Add-Member -MemberType NoteProperty -Name "Error" -Value "Error Processing Web $(($Entry.'Web URL').Replace($Entry.'Source Site URL', $Entry.'Destination Site URL'))"
                        $ValidationSummary.Add($ErrorObject) |Out-Null
                    }
                    Remove-Variable -Name SummaryInfo
                }

            }
            elseif($Entry.'Type of Entry' -eq "List")
            {
                if($Mode = "ItemCount")
                {
                    $SummaryInfo = $Entry | Get-SPOListMigrationValidation -Credential $Credential
                    if($SummaryInfo)
                    {
                        $ValidationSummary.Add($SummaryInfo) | Out-Null
                    }
                    else
                    {
                        $ErrorObject = New-Object System.Object
                        $ErrorObject | Add-Member -MemberType NoteProperty -Name "Type of Entry" -value "List"
                        $ErrorObject | Add-Member -MemberType NoteProperty -Name "Destination Web URL" -Value $(($Entry.'Web URL').Replace($Entry.'Source Site URL', $Entry.'Destination Site URL'))
                        $ErrorObject | Add-Member -MemberType NoteProperty -Name "List Title" -value $Entry.'List Title'
                        $ErrorObject | Add-Member -MemberType NoteProperty -Name "Error" -Value "Error processing list `'$($entry.'List Title')`' in web $(($Entry.'Web URL').Replace($Entry.'Source Site URL', $Entry.'Destination Site URL'))"
                        $ValidationSummary.Add($ErrorObject) | Out-Null
                    }
                    Remove-Variable -Name SummaryInfo
                }

            }
            elseif($Entry.'Type of Entry' -eq "WorkflowAssociation")
            {
                if($Mode = "ItemCount")
                {
                    $SummaryInfo = $Entry | Get-SPOListWorkflowAssociationValidation -Credential $Credential
                }
            }
        }

    }
    if(!($OutputFile.LocalPath))
    {
        $OutputFile = Get-URIFromString $OutputFile.OriginalString
    }
    $ValidationSummary | ConvertTo-Json | Out-File $OutputFile.LocalPath
}