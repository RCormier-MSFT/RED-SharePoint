<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will set the version configuration of each library listed in the input file to the values provided to the cmdlet
#>

function Set-SPLibraryVersionConfiguration
{
    [cmdletbinding()]
    param(
        [parameter(mandatory=$True, position=0, HelpMessage="Specify the path to the csv file containing all lists for which you would like to set version information" )]
        [ValidateScript({if($_.localpath.endswith("csv")){$True}else{throw "`r`n`'InputFile`' must be a csv file"}})]
        [URI]$InputFile,
        [parameter(mandatory=$False, Position=1, HelpMessage="Use this switch to identify whether or not Versions are enabled")]
        [switch]$VersionsEnabled,
        [parameter(mandatory=$False, Position=2, HelpMessage="Specify the maximum number of major versions to retain")]
        [ValidateScript({if($_ -gt 0 -and $_ -le 500){$True}else{throw "`r`n`'MaxMajorVersions`' must be between 0 and 500"}})]
        [int32]$MaxMajorVersions,
        [parameter(mandatory=$False, position=3, HelpMessage="Use this switch to identify whether or not minor versions are enabled")]
        [switch]$MinorVersionsEnabled,
        [parameter(mandatory=$False, Position=4, HelpMessage="Specify the number of major versions for which we will retain minor versions")]
        [ValidateScript({if($_ -gt 0 -and $_ -le 500){$True}else{throw "`r`n`'MaxMajorVersionsToRetainMinorVersions`' must be between 0 and 500"}})]
        [int32]$MaxMajorVersionsToRetainMinorVersions,
        [parameter(mandatory=$False, Position=5, HelpMessage="Specify whether or not to update all list items, forcing versions to be trimmed if necessary")]
        [Switch]$UpdateAllItems=$False
    )

    if(!(Test-Path -Path $InputFile.LocalPath))
    {
        Write-Host "Could not find file at path `'$($Inputfile.LocalPath)`'" -ForegroundColor Red
        Exit
    }
    [Array]$Lists = Import-Csv $InputFile.LocalPath
    [Array]$Webs = $lists | Select-Object weburl -Unique
    foreach($Web in $Webs)
    {
        $SPWeb = get-spweb $web.weburl
        foreach($List in ($Lists | Where-Object {$_.weburl -eq $web.weburl}))
        {
            $SPList = $SPWeb.Lists[$List.ListTitle]
            if($VersionsEnabled -or $MaxMajorVersions -or $MinorVersionsEnabled -or $MaxMajorVersionsToRetainMinorVersions)
            {
                $SPList.EnableVersioning = $True
                if($MinorVersionsEnabled)
                {
                    $SPList.EnableMinorVersions = $True
                }
                if($MaxMajorVersions)
                {
                    $SPList.MajorVersionLimit = $MaxMajorVersions
                }
                if($MaxMajorVersionsToRetainMinorVersions)
                {
                    if($MaxMajorVersionsToRetainMinorVersions -ge $MaxMajorVersions)
                    {
                        $SPList.MajorWithMinorVersionsLimit = $MaxMajorVersions
                    }
                    else
                    {
                        $SPList.MajorWithMinorVersionsLimit = $MaxMajorVersionsToRetainMinorVersions

                    }
                }
            }
            else
            {
                $SPList.EnableVersioning = $False
            }
            $SPlist.update()
            if($UpdateAllItems)
            {
                Save-SPLibraryVersionConfiguration $SPList
            }
        }
        $SPWeb.Dispose()
    }

}


