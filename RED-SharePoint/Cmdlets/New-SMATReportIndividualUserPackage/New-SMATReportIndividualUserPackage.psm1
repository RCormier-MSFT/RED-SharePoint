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
    [URI]$OutputDirectory
    )

    $OutputDirectory = Get-URIFromString $OutputDirectory.OriginalString
    if(!(Test-path $OutputDirectory.localpath))
    {
        Write-Verbose "Creating directory at `'$($OutputDirectory.localpath)`'."
        New-Item -ItemType Directory -Path $OutputDirectory.LocalPath | Out-Null
        if(Test-Path $OutputDirectory.localpath)
        {
            Write-Verbose "Directory has been successfully created"
        }
    }

    $OutputFile = Join-Path $OutputDirectory.LocalPath ($user.Replace("\","_")+".csv")

    $UserFiles = Import-Csv $InputFile.LocalPath | Where-Object {$_.CheckedOutUser -like "*$($User)]"} | Select-Object SiteURL, File
    write-host $UserFiles.count
    $UserFiles | Export-Csv -Path $OutputFile  -NoTypeInformation -Force

}





