<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will parse through a SMAT Checked Out Files report (in csv) and create an excel summary file for a single user.
#>

function New-SMATReportIndividualUserPackage
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0)]
    [ValidateScript({if($_.localpath.endswith("csv")){$True}else{throw "`r`n`'InputFile`' must be a csv file"}})]
    [URI]$InputFile,
    [parameter(Mandatory=$True, Position=1)]
    [ValidateScript({if(($_ -imatch '^\w+[\\]\w+') -or ($_ -imatch 'i:0#.w|^\w+[\\]\w+') ){$True}else{throw "`r`nUser value supplied must be a format recognized by SharePoint`r`nex: Domain\User or i:0#.w|Domain\User"}})]
    [String]$User,
    [Parameter(Mandatory=$False, Position=2)]
    [URI]$OutputDirectory,
    [parameter(Mandatory=$False, Position=3, ParameterSetName="SendMail")]
    [Switch]$SendMail,
    [Parameter(Mandatory=$True, Position=4)]
    [ValidateSet("HTML", "CSV")]
    [String]$Format="HTML"
    )
    DynamicParam
    {
        if ($Sendmail)
        {
            $SMTPServerAttribute = New-Object System.Management.Automation.ParameterAttribute
            $SMTPServerAttribute.HelpMessage = "Please specify the SMTP Server:"
            $SMTPServerAttribute.Mandatory = $True
            $SMTPServerAttribute.Position = 4
            $smtpserverAttribute.ParameterSetName = "SendMail"
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
            $SMTPServerParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SMTPServer', [String], $SMTPServerAttributeCollection)
            $SMTPFromAddressParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SMTPFromAddress', [String], $SMTPFromAddressAttributeCollection)
            $SMTPReplyToAddressParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SMTPReplyToAddress', [String], $SMTPReplyToAddressAttributeCollection)
            $SMTPCCAddressParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SMTPCCAddress', [String], $SMTPCCAddressAttributeCollection)
            $SMTPBodyFileParam = New-Object System.Management.Automation.RuntimeDefinedParameter('SMTPBodyFile', [URI], $SMTPBodyFileAttributeCollection)
            $paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('SMTPServer', $SMTPServerParam)
            $paramDictionary.Add('SMTPFromAddress', $SMTPFromAddressParam)
            $paramDictionary.Add('SMTPReplyToAddress', $SMTPReplyToAddressParam)
            $paramDictionary.Add('SMTPCCAddress', $SMTPCCAddressParam)
            $paramDictionary.Add('SMTPBodyFile', $SMTPBodyFileParam)
            return $paramDictionary
        }
    }
    Begin
    {
        $OutputDirectory = Get-URIFromString $OutputDirectory.OriginalString
    }
    Process
    {
        if(!(Test-path $OutputDirectory.localpath))
        {
            Write-Verbose "Creating directory at `'$($OutputDirectory.localpath)`'."
            New-Item -ItemType Directory -Path $OutputDirectory.LocalPath | Out-Null
            if(Test-Path $OutputDirectory.localpath)
            {
                Write-Verbose "Directory has been successfully created"
            }
        }
        $Username = $User.Substring($User.IndexOf("|")+1, ($User.IndexOf("]") - $User.IndexOf("|")-1))
        $OutputFile = Join-Path $OutputDirectory.LocalPath "$($Username.replace("\","_")).csv"
        $AllInput = Import-CSV $InputFile.LocalPath
        if(($AllInput | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) -match "SharePointUserSIDFoundInAD" )
        {
            $UserFiles = $AllInput | Where-Object {($_.CheckedOutUser -like "*$($Username)*") -and ($_.SharePointUserSIDFoundInAD -eq "Yes")}
        }
        else
        {
            $UserFiles = $AllInput | Where-Object {$_.CheckedOutUser -like "*$($Username)*"}
        }

        if($Format -match "CSV")
        {
            $UserFiles | Export-Csv -Path $OutputFile  -NoTypeInformation -Force
        }
        else
        {
            $Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@
            $Outputfile = $OutputFile.Replace(".csv",".html")
            $OutputTable = New-Object System.Collections.Arraylist
            if((Import-CSV $InputFile.LocalPath | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name) -match "ListID")
            {
                foreach($Entry in $UserFiles)
                {
                    $TableInfo = New-Object System.Object
                    $TableInfo | Add-Member -MemberType NoteProperty -Name SiteURL -Value "$($Entry.SiteURL)"
                    $TableInfo | Add-Member -MemberType NoteProperty -name WebURL -value "$($Entry.WebURL)"
                    $TableInfo | Add-Member -MemberType NoteProperty -name "Check-in Link" -Value "<a href=`"$($Entry.WebURL)/_layouts/15/checkin.aspx?List={$($Entry.ListID)}&filename=$($Entry.File.substring($Entry.file.indexof("/", $Entry.File.Indexof("//")+2)))`">$($Entry.File)</a>"
                    $OutputTable.Add($TableInfo) | Out-Null
                    if($TableInfo)
                    {
                        Remove-Variable -Name TableInfo
                    }
                }
            }
            else
            {
                foreach($Entry in $UserFiles)
                {
                    $TableInfo = new-object System.Object
                    $TableInfo | Add-Member -MemberType NoteProperty -Name SiteURL -Value "$($Entry.SiteURL)"
                    $TableInfo | Add-Member -MemberType NoteProperty -Name WebURL -value "$($Entry.WebURL)"
                    $TableInfo | Add-Member -MemberType NoteProperty -Name FileURL -Value "<a href=`"$($Entry.File)`">$($Entry.File)</a>"
                    $OutputTable.Add($TableInfo) | Out-Null
                    if($TableInfo)
                    {
                        Remove-Variable -Name TableInfo
                    }
                }


            }
            Add-Type -AssemblyName System.Web
            [System.Web.HttpUtility]::HtmlDecode(($OutputTable | ConvertTo-Html -As Table -Head $Header)) | Out-File $OutputFile -Force | Out-Null
        }

        if($Sendmail)
        {
            $Expression = "New-SMATReportCheckedOutFilesEmail -SMTPServer `$PSBoundParameters.SMTPServer -SMTPMailSubject  `"Individual user checked out files report for user `$(`$Username)`" -SMTPToAddress (Get-ADUser -Filter `"SAMAccountName -eq '`$(`$Username.Substring(`$Username.IndexOf(`"\`")+1))'`" | Select-Object -ExpandProperty UserPrincipalName) -SMTPFromAddress `$PSBoundParameters.SMTPFromAddress -SMTPReplyToAddress `$PSBoundParameters.SMTPReplyToAddress -SMTPBodyFile `$PSBoundParameters.SMTPBodyFile.localpath -AttachmentFile `$OutputFile"
            if($PSBoundParameters.SMTPCCAddress)
            {
                $Expression = "$($Expression) -SMTPCCAddress `$PSBoundParameters.SMTPCCAddress"
            }
            Invoke-Expression $Expression

        }

    }

}





