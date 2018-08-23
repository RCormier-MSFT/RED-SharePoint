<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will produce a report detailing the version settings for all document libraries in a site collection
#>
function New-SPVersionReport
{
    [cmdletbinding()]
    param(
    [parameter(mandatory=$true, position=0, HelpMessage="This is the URL of the site collection where we would like to produce the report.", ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({if(get-spsite $_.originalstring){$True}else{throw "`r`nSite at URL `'$($_.Originalstring)`' does not exist"}})]
    [Alias('URL')]
    [URI]$SiteURL,
    [parameter(mandatory=$False, position=1, HelpMessage="This is the name of the list you would like to target")]
    [String]$ListName,
    [parameter(mandatory=$False, position=2, HelpMessage="This is the name of the output file")]
    [Validatescript({if($_.localpath.endswith(".csv")){$True}else{throw "`r`n`'OutputFile`' must be a csv file"}})]
    [URI]$OutputFile=".\ListVersions.csv",
    [parameter(mandatory=$False, position=3, HelpMessage="Use this switch to overwrite the specified csv file")]
    [Switch]$Force
    )
    $OutputFile = Get-URIFromString $OutputFile.OriginalString
    if(Test-Path -Path $OutputFile.LocalPath)
    {
        if(!($Force))
        {
            write-Host "File at path `'$($Outputfile.localpath)`' already exists`r`nUse the `-Force`' switch to overwrite the file" -ForegroundColor Red
            exit
        }
    }
    $SPSite = Get-SPSite $SiteURL.OriginalString
    $ListVersionsReport = New-Object System.Collections.ArrayList
    foreach($Web in $SPSite.AllWebs)
    {
        foreach($List in $web.lists)
        {

            if($List.BaseType -eq "DocumentLibrary" -and ($List.title -ne "Master Page Gallery" -and $List.title -ne "This Week in Pictures Library"))
            {
            $ListInformation = New-Object System.Object
            $ListInformation | Add-Member -MemberType NoteProperty -Name "WebURL" -Value $Web.URL
            $ListInformation | Add-Member -MemberType NoteProperty -Name "ListTitle" -Value $List.Title
            $ListInformation | Add-Member -MemberType NoteProperty -Name "VersioningEnabled" -Value $List.EnableVersioning
            if($List.MajorVersionLimit -ne 0)
            {
                $ListInformation | Add-Member -MemberType NoteProperty -Name "MajorVersionLimit" -value $List.MajorVersionLimit
            }
            else
            {
                $ListInformation | Add-Member -MemberType NoteProperty -Name "MajorVersionLimit" -Value "No Limit"
            }
            $ListInformation | Add-Member -MemberType NoteProperty -Name "MinorVersionsEnabled" -value $List.EnableMinorVersions
            if($List.MajorWithMinorVersionsLimit -ne 0)
            {
                $ListInformation | Add-Member -MemberType NoteProperty -Name "MajorVersionsWithMinorVersions" -Value $list.MajorWithMinorVersionsLimit
            }
            else
            {
                $ListInformation | Add-Member -MemberType NoteProperty -Name "MajorVersionsWithMinorVersions" -Value "No Limit"
            }
            $ListVersionsReport.Add($ListInformation) | Out-Null
            }
        }
        $web.dispose()
    }
    if(!(Test-Path $OutputFile.LocalPath.Substring(0,$OutputFile.LocalPath.LastIndexOf("\"))))
    {
        New-Item -Path $OutputFile.LocalPath.Substring(0,$OutputFile.LocalPath.LastIndexOf("\")) -ItemType Directory
    }
    $ListVersionsReport | Export-Csv -Path $OutputFile.LocalPath -NoTypeInformation -Force
}


