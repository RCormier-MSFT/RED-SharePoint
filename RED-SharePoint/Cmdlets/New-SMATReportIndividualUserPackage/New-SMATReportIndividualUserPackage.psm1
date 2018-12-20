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
    [Switch]$Sendmail
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

        $UserFiles = Import-Csv $InputFile.LocalPath | Where-Object {$_.CheckedOutUser -like "*$($Username)*"} | Select-Object SiteURL, File
        $UserFiles | Export-Csv -Path $OutputFile  -NoTypeInformation -Force

        if($Sendmail)
        {
            New-SMATReportCheckedOutFilesEmail -SMTPServer $PSBoundParameters.SMTPServer -SMTPMailSubject  "Individual user checked out files report for user $($Username)" -SMTPToAddress (Get-ADUser -Filter "SAMAccountName -eq '$($Username.Substring($Username.IndexOf("\")+1))'" | Select-Object -ExpandProperty UserPrincipalName) -SMTPFromAddress $PSBoundParameters.SMTPFromAddress -SMTPReplyToAddress $PSBoundParameters.SMTPReplyToAddress -SMTPCCAddress $PSBoundParameters.SMTPCCAddress -SMTPBodyFile $PSBoundParameters.SMTPBodyFile.localpath -AttachmentFile $OutputFile
        }

    }

}





