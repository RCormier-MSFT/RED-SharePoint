<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will parse through a SMAT Checked Out Files report (in csv) and return how long it has been since each file was checked out
#>

function New-SMATReportCheckedOutFilesSummary
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0)]
    [ValidateScript({if($_.localpath.endswith("csv")){$True}else{throw "`r`n`'InputFile`' must be a csv file"}})]
    [URI]$InputFile,
    [parameter(mandatory=$False, position=1, HelpMessage="This is the name of the output file")]
    [Validatescript({if($_.localpath.endswith(".csv")){$True}else{throw "`r`n`'OutputFile`' must be a csv file"}})]
    [URI]$OutputFile=".\SMATCheckedOutFileReport.csv",
    [Parameter(mandatory=$False, position=2, HelpMessage="A site collection can optionally be specified, to process only a subset of a SMAT report")]
    [String]$SiteURL,
    [Parameter(mandatory=$False, position=3, HelpMessage="Specify a threshold, in days, to use as an indicator in the summary report.  Default value is 60 days")]
    [Int32]$ReportThresholdInDays=60,
    [Parameter(mandatory=$False, position=4, HelpMessage="Use this switch to overwrite existing SMAT checked out file report")]
    [switch]$Force
    )
    $OutputFile = Get-URIFromString $OutputFile.OriginalString
    if((Test-Path $($OutputFile.LocalPath)) -and (!$Force))
    {
        Write-Error "`r`nOutputFile `'$($OutputFile.LocalPath)`' already exists.  Specify a new path or use the `'-Force`' switch to overwrite the file"
        exit
    }
    else
    {
        $AllItems = Import-Csv $InputFile.LocalPath
        if($SiteURL)
        {
            [Array]$AllSites = $SiteURL
        }
        else
        {
            [Array]$AllSites = Get-SMATReportUniqueSites -InputFile $InputFile.LocalPath
        }
        $FileReport = New-Object System.Collections.ArrayList
        foreach($Site in $AllSites)
        {
            Write-Progress -Activity "Processing sites" -Status "Processing site ($($Allsites.IndexOf($site)+1) of $($Allsites.count)) - $($Site)" -PercentComplete(($AllSites.IndexOf($Site)/$AllSites.Count*100)) -Id 1
            $SPSite = get-spsite $Site
            [Array]$Files = $AllItems | Where-Object {$_.SiteURL -eq $Site}
            ForEach($File in $Files)
            {
                Write-Progress -Activity "Processing Checked Out Files" -Status "Processing file $($Files.IndexOf($file)+1) of $($Files.Count)" -PercentComplete (($files.IndexOf($file)/$files.Count*100)) -ParentId 1
                $FileInformation = New-Object System.Object
                $FileInformation | Add-Member -MemberType NoteProperty -Name "SiteURL" -Value $File.SiteURL
                $FileInformation | Add-Member -MemberType NoteProperty -Name "File URL" -Value $File.File
                $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out To" -Value $File.CheckedOutUser
                Try
                {
                    [DateTime]$CheckOutDate = $SPSite.rootweb.GetFile($File.File).checkedoutdate
                    $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Date" -Value $CheckOutDate
                    $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Days" -value $((Get-Date).Subtract($CheckOutDate).Days)
                    if((get-date).Subtract($CheckOutDate).days -gt $ReportThresholdInDays)
                    {
                        $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "True"
                    }
                    else
                    {
                        $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "False"
                    }
                }
                Catch
                {
                    $CheckedOutFile = $SPSite.rootweb.GetFile($File.File)
                    if($file.file -match "/Lists/")
                    {
                        if(((Get-SPWeb ("$($CheckedOutFile.Web.Site.URL)/$($CheckedOutFile.url.Substring(0,$CheckedOutFile.Url.Indexof("/Lists")))")).Lists | Where-Object {$_.RootFolder.Name -eq $CheckedOutFile.ParentFolder.Name}).basetype -eq "Survey")
                        {
                            $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Date" -Value "Incomplete Survey" -Force
                            $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Days" -value "Incomplete Survey" -Force
                            $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "Incomplete Survey" -Force

                        }
                    }
                    ElseIf($CheckedOutFile.InDocumentLibrary -eq "True")
                    {
                        if(($CheckedOutFile.Web.Lists[$CheckedOutFile.documentlibrary.title]).CheckedOutFiles.count -ge 1)
                        {
                            if((($CheckedOutFile.Web.Lists[$CheckedOutFile.documentlibrary.title]).CheckedOutFiles | Select-Object -ExpandProperty url).startswith($CheckedOutFile.ServerRelativeURL.Substring(1)))
                            {
                                $CheckedOutFileInfo = ($CheckedOutFile.web.Lists[$CheckedOutFile.documentlibrary.title]).CheckedOutFiles | Where-Object {$_.url -eq $CheckedOutFile.ServerRelativeURL.Substring(1)}
                                $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Date" -Value ($CheckedOutFileInfo.TimeLastModified) -Force
                                $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Days" -value $((Get-Date).Subtract($CheckedOutFileInfo.TimeLastModified).Days) -Force
                                if((get-date).Subtract($CheckedOutFileInfo.TimeLastModified).days -gt $ReportThresholdInDays)
                                {
                                    $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "True" -Force
                                }
                                else
                                {
                                    $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "False" -Force
                                }
                            }
                            else
                            {
                                $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Date" -Value "File is no longer checked out" -force
                                $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Days" -value "File is no longer checked out" -force
                                $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "File is no longer checked out" -force
                            }
                        }
                        else
                        {
                            $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Date" -Value "No checked out files in list" -force
                            $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Days" -value "No checked out files in list" -force
                            $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "No checked out files in list" -force
                        }
                    }
                    else
                    {
                        $FileAlreadyCheckedIn = $True
                        foreach($web in ($CheckedOutFile.web.site.allwebs | Where-Object {$CheckedOutFile.ServerRelativeURL.startswith($_.RootFolder.ServerRelativeURL)}))
                        {
                            $lists = $web.lists | Where-Object {$_ -is [Microsoft.SharePoint.SPDocumentLibrary]}
                            foreach($list in ($lists | Where-Object {$CheckedOutFile.ServerRelativeURL.startswith($_.RootFolder.ServerRelativeURL)}))
                            {
                                $FoundFile = $list.CheckedOutFiles | Where-Object {$_.url -eq $CheckedOutFile.ServerRelativeurl.substring(1)}
                                if($FoundFile)
                                {
                                    $FileAlreadyCheckedIn = $False
                                    $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Date" -Value ($FoundFile.TimeLastModified) -Force
                                    $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Days" -value $((Get-Date).Subtract($FoundFile.TimeLastModified).Days) -Force
                                    if((get-date).Subtract($FoundFile.TimeLastModified).days -gt $ReportThresholdInDays)
                                    {
                                        $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "True" -Force
                                    }
                                    else
                                    {
                                        $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "False" -Force
                                    }
                                    Break
                                }
                            }
                            if($FoundFile)
                            {
                                Remove-Variable -name FoundFile
                                Break
                            }
                        }
                        if($FileAlreadyCheckedIn -eq $True)
                        {
                            $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Date" -Value "File is no longer checked out" -force
                            $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked Out Days" -value "File is no longer checked out" -force
                            $FileInformation | Add-Member -MemberType NoteProperty -Name "Checked out More than $($ReportThresholdInDays) days?" -Value "File is no longer checked out" -force
                        }
                    }


                }
                $FileReport.Add($FileInformation) | Out-Null
                Remove-Variable -Name Fileinformation -ErrorAction SilentlyContinue
            }

            $SPSite.Dispose()
        }

        if(!(Test-Path $OutputFile.LocalPath.Substring(0,$OutputFile.LocalPath.LastIndexOf("\"))))
        {
            New-Item -Path $OutputFile.LocalPath.Substring(0,$OutputFile.LocalPath.LastIndexOf("\")) -ItemType Directory
        }
    }
    $FileReport | Export-Csv -Path $OutputFile.LocalPath -NoTypeInformation -Force
    Write-Progress -Activity "Processing Checked Out Files" -Status "Completed" -PercentComplete 100 -Completed
}
