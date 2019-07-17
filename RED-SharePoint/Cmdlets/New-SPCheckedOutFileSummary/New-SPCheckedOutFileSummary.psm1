Function New-SPCheckedOutFilesSummary
{
    [cmdletbinding()]
    param(
    [Parameter(mandatory=$True, position=0, HelpMessage="Site Collection URL for which the summary report should be prepared")]
    [URI]$SiteURL,
    [parameter(mandatory=$False, position=1, HelpMessage="The directory that the summary file should be placed in")]
    [URI]$OutputDirectory,
    [parameter(mandatory=$True, position=2, HelpMessage="The emails to generate from the summary")]
    [ValidateSet("None","UserOnly", "SiteOwnerOnly","UserAndSiteOwner")]
    [String]$EmailsToSend,
    [parameter(mandatory=$False, position=3, HelpMessage="Use this switch to indicate that you have multiple domains")]
    [Switch]$MultiDomain
    )
    DynamicParam
    {
        $paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
        if (-not ([String]::IsNullOrEmpty($EmailsToSend)) -and ($EmailsToSend -ne "None"))
        {
            $SMTPServerAttribute = New-Object System.Management.Automation.ParameterAttribute
            $SMTPServerAttribute.HelpMessage = "Please specify the SMTP Server:"
            $SMTPServerAttribute.Mandatory = $True
            $SMTPServerAttribute.Position = 4
            $smtpServerAttribute.ParameterSetName = "SendMail"
            $SMTPFromAddressAttribute = New-Object System.Management.Automation.ParameterAttribute
            $SMTPFromAddressAttribute.HelpMessage = "Please enter the SMTP From Address:"
            $SMTPFromAddressAttribute.Mandatory = $True
            $SMTPFromAddressAttribute.Position = 5
            $SMTPFromAddressAttribute.ParameterSetName = "SendMail"
            $SMTPReplyToAddressAttribute = New-Object System.Management.Automation.ParameterAttribute
            $SMTPReplyToAddressAttribute.HelpMessage = "Please enter the SMTP Reply Address:"
            $SMTPReplyToAddressAttribute.Mandatory = $True
            $SMTPReplyToAddressAttribute.Position = 6
            $SMTPReplyToAddressAttribute.ParameterSetName = "SendMail"
            $SMTPCCAddressAttribute = New-Object System.Management.Automation.ParameterAttribute
            $SMTPCCAddressAttribute.HelpMessage = "Please enter an address to CC on the e-mail:"
            $SMTPCCAddressAttribute.Mandatory = $False
            $SMTPCCAddressAttribute.position = 7
            $SMTPCCAddressAttribute.ParameterSetName = "SendMail"
            $SMTPBodyFileAttribute = New-Object System.Management.Automation.ParameterAttribute
            $SMTPBodyFileAttribute.HelpMessage = "Specify the file to use as a standard e-mail body"
            $SMTPBodyFileAttribute.Mandatory = $True
            $SMTPBodyFileAttribute.Position = 8
            $SMTPBodyFileAttribute.ParameterSetName = "SendMail"
            $FileFormatAttribute = New-Object System.Management.Automation.ParameterAttribute
            $FileFormatAttribute.HelpMessage = "Specify the type of file you would like to provide to end-users"
            $FileFormatAttribute.Mandatory = $True
            $FileFormatAttribute.Position = 9
            $FileFormatAttribute.ParameterSetName = "SendMail"
            $SMTPServerAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $SMTPServerAttributeCollection.Add($SMTPServerAttribute)
            $SMTPFromAddressAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $SMTPFromAddressAttributeCollection.Add($SMTPFromAddressAttribute)
            $SMTPReplyToAddressAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $SMTPReplyToAddressAttributeCollection.Add($SMTPReplyToAddressAttribute)
            $SMTPCCAddressAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $SMTPCCAddressAttributeCollection.Add($SMTPCCAddressAttribute)
            $SMTPBodyFileAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $SMTPBodyFileAttributeCollection.Add($SMTPBodyFileAttribute)
            $FileFormatAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $FileFormatAttributeCollection.Add($FileFormatAttribute)
            $FileFormatValidationOptions=@("CSV", "HTML")
            $FileFormatValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($FileFormatValidationOptions)
            $FileFormatAttributeCollection.Add($FileFormatValidateSetAttribute)
            $SMTPServerParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SMTPServer', [String], $SMTPServerAttributeCollection)
            $SMTPFromAddressParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SMTPFromAddress', [String], $SMTPFromAddressAttributeCollection)
            $SMTPReplyToAddressParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SMTPReplyToAddress', [String], $SMTPReplyToAddressAttributeCollection)
            $SMTPCCAddressParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SMTPCCAddress', [String], $SMTPCCAddressAttributeCollection)
            $SMTPBodyFileParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SMTPBodyFile', [URI], $SMTPBodyFileAttributeCollection)
            $FormatParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Format', [String], $FileFormatAttributeCollection)
            $paramDictionary.Add('SMTPServer', $SMTPServerParam)
            $paramDictionary.Add('SMTPFromAddress', $SMTPFromAddressParam)
            $paramDictionary.Add('SMTPReplyToAddress', $SMTPReplyToAddressParam)
            $paramDictionary.Add('SMTPCCAddress', $SMTPCCAddressParam)
            $paramDictionary.Add('SMTPBodyFile', $SMTPBodyFileParam)
            $paramDictionary.Add('Format', $FormatParam)

        }
        if($MultiDomain)
        {
            $MultiDomainCSVAttribute = New-Object System.Management.Automation.ParameterAttribute
            $MultiDomainCSVAttribute.HelpMessage = "Specify the file that contains information about your domains"
            $MultiDomainCSVAttribute.Mandatory = $False
            $MultiDomainCSVAttribute.Position = 10
            $MultiDomainCSVAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $MultiDomainCSVAttributeCollection.Add($MultiDomainCSVAttribute)
            $MultiDomainValidateScriptAttribute = New-Object -TypeName System.Management.Automation.ValidateScriptAttribute([System.Management.Automation.ScriptBlock]::Create("if(`$_.localpath.endswith(`".csv`")){`$True}else{Throw `"`$MultiDomainCSV must be a CSV file`"}"))
            $MultiDomainCSVAttributeCollection.Add($MultiDomainValidateScriptAttribute)
            $MultiDomainCSVParam = New-Object System.Management.Automation.RuntimeDefinedParameter('MultiDomainCSV', [URI], $MultiDomainCSVAttributeCollection)
            $paramDictionary.Add('MultiDomainCSV', $MultiDomainCSVParam)


        }
        return $paramDictionary
    }
    Begin
    {
            Write-Progress -Activity "Processing site $($SiteURL)" -Status "Retrieving Site Collection" -PercentComplete 0 -id 1
            $CheckedOutFileSummary = New-Object System.Collections.Arraylist
            if(-not $OutputDirectory)
            {
                $OutputDirectory = (Get-Location | Select-Object -ExpandProperty path)
            }
            if(-not (Test-Path $OutputDirectory.AbsolutePath))
            {
                New-Item -Path $OutputDirectory.AbsolutePath -ItemType Directory | Out-Null
            }
            $OutputFile = (join-path $OutputDirectory.AbsolutePath "$(Get-Date -Format MM-dd-yyyy)_$($SiteURL.originalstring.Substring($SiteURL.originalstring.LastIndexOf("//")+2).replace(".","_").replace("/","_"))CheckedOutFiles_Master.csv")
            if($MultiDomain -and (-not ($PSBoundParameters.MultiDomainCSV)))
            {
                $AllDomainInfo = Get-DomainsFromADForest
            }
            elseif($MultiDomain -and (-not [String]::IsNullOrEmpty($PSBoundParameters.MultiDomainCSV.localpath)))
            {
                $AllDomainInfo = Import-Csv $PSBoundParameters.MultiDomainCSV.localpath
                write-host $PSBoundParameters.multidomaincsv.localpath
            }

    }
    Process
    {
        $CurrentSPSite = Get-SPSite $SiteURL.OriginalString
        if(-not ([String]::IsNullOrEmpty($currentSPSite.url)))
        {
            Write-Progress -Activity "Processing Site $($SiteURL)" -Status "Retrieved Site Collection" -PercentComplete 100 -id 1
            Write-Progress -Activity "Processing Site $($SiteURL)" -Status "Retrieving All Webs" -PercentComplete 0 -Id 1
            [Array]$AllWebs = $CurrentSPSite.allwebs
            Write-Progress -Activity "Processing Site $($SiteURL)" -Status "Retrieved $($AllWebs.count) webs" -PercentComplete 100 -id 1
            Write-Progress -Activity "Processing Site $($SiteURL)" -Status "Processing Webs" -PercentComplete 0 -id 1
            foreach($Web in $AllWebs)
            {
                Write-Progress -Activity "Processing Site $($SiteURL)" -Status "Processing Webs" -PercentComplete $(($AllWebs.Indexof($web)/$AllWebs.count)*100) -Id 1
                Write-Progress -Activity "Processing Web $($Web.url)" -Status "Retrieving Libraries" -PercentComplete 0 -ParentId 1
                $Libraries = $Web.Lists | Where-Object {$_ -is [Microsoft.SharePoint.SPDocumentLibrary]}
                Write-Progress -Activity "Processing Web $($Web.url)" -Status "Retrieved $($Libraries.count) Libraries" -PercentComplete 100 -ParentId 1
                foreach($Library in $Libraries)
                {
                    Write-Progress -Activity "Processing Web $($Web.url)" -Status "Retrieving checked out files in list `'$($Library.title)`'" -PercentComplete $(($Libraries.indexof($Library)/$Libraries.count)*100) -ParentId 1
                    [Array]$AllCheckedOutFiles = $Library.Items | Where-Object {-not ([String]::IsNullOrEmpty($_.file.CheckedOutByUser))}
                    [Array]$AllCheckedOutFilesWithNoVersion = $Library.CheckedOutFiles
                    if($AllCheckedOutFiles.count -gt 0)
                    {
                        $UserLookup=@{}
                        foreach($file in $AllCheckedOutFiles)
                        {
                            Write-Progress -Activity "Processing checked out files" -Status "Processing file $($Web.url+$File.url)" -PercentComplete 100 -ParentId 2
                            $CheckedOutFileInformation = New-Object System.Object
                            $CheckedoutFileInformation | Add-Member -MemberType NoteProperty -Name 'SiteURL' -Value $SiteURL
                            if($PSBoundParameters.Format -eq "HTML")
                            {
                                $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -name 'WebURL' -value $Web.url
                                $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name 'ListID' -value $Library.ID
                            }
                            $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name 'SiteOwner' -value $CurrentSPSite.owner.UserLogin
                            $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name 'SiteAdmins' -Value ($CurrentSPSite.RootWeb.SiteAdministrators -join ";")
                            $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name 'File' -value "$($Web.url)/$($File.url)"
                            $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name 'CheckedOutUser' -Value "$($File.File.CheckedOutByUser.DisplayName)[$($File.File.CheckedOutByUser)]"
                            $SharePointUserSID = $File.File.CheckedOutByUser.SystemUserKey.SubString($File.File.CheckedOutByUser.SystemUserKey.LastIndexOf("|")+1)
                            $ADExpression = "Get-ADUser -Filter 'SID -eq `$SharePointUserSID' -ErrorAction SilentlyContinue"
                            if($MultiDomain)
                            {
                                $DomainSID = $SharePointUserSID.Substring(0,$SharePointUserSID.LastIndexOf("-"))
                                $DomainName = $AllDomainInfo | where-object {$DomainSID -match $_.DomainSID} | Select-Object -ExpandProperty DomainFQDN
                                $ADExpression  = "$($ADExpression) -Server $($DomainName)"
                            }
                            Try
                            {
                                if(-not ($UserLookup["$($SharePointUserSID)"]))
                                {
                                    $ADUser = Invoke-Expression $ADExpression
                                    Remove-Variable -Name ADExpression
                                }
                                elseif($UserLookup["$($SharePointUserSID)"] -eq "True")
                                {
                                   $ADUser = $True
                                }

                            }
                            Catch
                            {
                                Write-Host "Could not find user with SID $($SharePointUserSID)" -ForegroundColor Yellow
                            }
                            if($ADUser)
                            {
                                if(-not ($UserLookup["$($SharePointUserSID)"]))
                                {
                                    $UserLookup.Add("$($SharePointUserSID)", "True")
                                }
                                $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name "SharePointUserSIDFoundInAD" -value "Yes"
                                if($ADUser)
                                {
                                    Remove-Variable -Name ADUser
                                }
                            }
                            else
                            {
                                if(-not ($UserLookup["$($SharePointUserSID)"]))
                                {
                                    $UserLookup.Add("$($SharePointUserSID)", "False")
                                }
                                $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name "SharePointUserSIDFoundInAD" -value "No"
                            }
                            $CheckedOutFileSummary.Add($CheckedOutFileInformation) | Out-Null
                            if($CheckedOutFileInformation)
                            {
                                Remove-Variable -Name CheckedOutFileInformation
                            }
                        }
                        foreach($File in $AllCheckedOutFilesWithNoVersion)
                        {
                            Write-Progress -Activity "Processing files with no checked in versions" -Status "Processing file $($Web.url+$File.url)" -PercentComplete 100 -ParentId 2
                            $CheckedOutFileInformation = New-Object System.Object
                            $CheckedoutFileInformation | Add-Member -MemberType NoteProperty -Name 'SiteURL' -Value $SiteURL
                            if($PSBoundParameters.Format -eq "HTML")
                            {
                                $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -name 'WebURL' -value $Web.url
                                $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name 'ListID' -value $Library.ID
                            }
                            $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name 'SiteOwner' -value $CurrentSPSite.owner.UserLogin
                            $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name 'SiteAdmins' -Value ($CurrentSPSite.RootWeb.SiteAdministrators -join ";")
                            if(($Web.URL -as [URI]).AbsolutePath -eq "/")
                            {
                                $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name 'File' -value "$($Web.url)/$($File.url)"
                            }
                            else
                            {
                                $CheckedOutFileInformation | add-member -MemberType NoteProperty -Name 'File' -Value "$($Web.url)/$($file.Url.Substring($Web.url.Substring($Web.url.IndexOf(`"/`", $Web.url.IndexOf(`"//`")+2)).length))"
                            }
                            $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name 'CheckedOutUser' -Value "$($File.CheckedOutBy.DisplayName)[$($File.CheckedOutBy.UserLogin)]"
                            $SharePointUserSID = $File.CheckedOutBy.SystemUserKey.SubString($File.CheckedOutBy.SystemUserKey.LastIndexOf("|")+1)
                            $ADExpression = "Get-ADUser -Filter 'SID -eq `$SharePointUserSID' -ErrorAction SilentlyContinue"
                            if($MultiDomain)
                            {
                                $DomainSID = $SharePointUserSID.Substring(0,$SharePointUserSID.LastIndexOf("-"))
                                $DomainName = $AllDomainInfo | where-object {$DomainSID -match $_.DomainSID} | Select-Object -ExpandProperty DomainFQDN
                                $ADExpression  = "$($ADExpression) -Server $($DomainName)"
                            }
                            Try
                            {
                                if(-not ($UserLookup["$($SharePointUserSID)"]))
                                {
                                    $ADUser = Invoke-Expression $ADExpression
                                    Remove-Variable -Name ADExpression
                                }
                                elseif($UserLookup["$($SharePointUserSID)"] -eq "True")
                                {
                                   $ADUser = $True
                                }

                            }
                            Catch
                            {
                                Write-Host "Could not find user with SID $($SharePointUserSID)" -ForegroundColor Yellow
                            }
                            if($ADUser)
                            {
                                if(-not ($UserLookup["$($SharePointUserSID)"]))
                                {
                                    $UserLookup.Add("$($SharePointUserSID)", "True")
                                }
                                $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name "SharePointUserSIDFoundInAD" -value "Yes"
                                if($ADUser)
                                {
                                    Remove-Variable -Name ADUser
                                }
                            }
                            else
                            {
                                if(-not ($UserLookup["$($SharePointUserSID)"]))
                                {
                                    $UserLookup.Add("$($SharePointUserSID)", "False")
                                }
                                $CheckedOutFileInformation | Add-Member -MemberType NoteProperty -Name "SharePointUserSIDFoundInAD" -value "No"
                            }
                            $CheckedOutFileSummary.Add($CheckedOutFileInformation) | Out-Null
                            if($CheckedOutFileInformation)
                            {
                                Remove-Variable -Name CheckedOutFileInformation
                            }
                        }
                        Remove-Variable -name UserLookup
                    }
                    else
                    {
                        Write-Progress -Activity "Processing web $($Web.url)" -Status "Did not retrieve any checked out files" -PercentComplete 100 -ParentId 2
                    }

                }
                Write-Progress -Activity "Processing web $($Web.url)" -Status "All Lists have been processed" -PercentComplete 100 -ParentId 1 -Completed
            }
            Write-Progress -Activity "Processing Site $($SiteURL)" -Status "Copmleted Processing" -PercentComplete 100
        }
    }
    End
    {
        Write-Progress -Activity "Processing Site $($SiteURL)" -Completed
        $CheckedOutFileSummary | ConvertTo-Csv -NoTypeInformation | Out-File $OutputFile -Force
        if(($EmailsToSend -match "User"))
        {
            $UniqueUsers = Get-SMATReportUniqueUsers -InputFile $OutputFile
            foreach($User in $UniqueUsers)
            {
                $Expression = "New-SMATReportIndividualUserPackage -InputFile `$OutputFile -User `$User -OutputDirectory `$OutputDirectory -SendMail -SMTPServer `$PSboundParameters.SMTPServer -SMTPFromAddress `$PSboundParameters.SMTPFromAddress -SMTPReplyToAddress `$PSboundParameters.SMTPReplyToAddress -SMTPBodyFile `$PSboundParameters.SMTPBodyFile -format `$PSBoundParameters.Format"
                if($PSBoundParameters.SMTPCCAddress)
                {
                    $Expression = "$($Expression) -SMTPCCAddress `$PSboundParameters.SMTPCCAddress"
                }
                Try
                {
                    Invoke-Expression $Expression
                }
                Catch
                {
                    Write-Warning "Encountered an error calling New-SMATReportIndividualUserPackage for user $($User)"
                }
            }

        }
        if($EmailsToSend -match "SiteOwner")
        {
            $Expression = "New-SMATReportSiteOwnerPackage -InputFile `$OutputFile -SiteOwner `$(`$CurrentSPSite.Owner.Userlogin) -OutputDirectory `$OutputDirectory -SendMail -SMTPServer `$PSboundParameters.SMTPServer -SMTPFromAddress `$PSboundParameters.SMTPFromAddress -SMTPReplyToAddress `$PSboundParameters.SMTPReplyToAddress -SMTPBodyFile `$PSboundParameters.SMTPBodyFile -format `$PSBoundParameters.Format"
            if($PSBoundParameters.SMTPCCAddress)
            {
                $Expression = "$($Expression) -SMTPCCAddress `$PSboundParameters.SMTPCCAddress"
            }
            Invoke-Expression $Expression
        }
    }
}
