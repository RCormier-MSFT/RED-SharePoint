<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet forces a check-in of all checked out files within a given site collection
#>

function New-BulkFileCheckIn
{
[CmdletBinding()]
param(
[Parameter(HelpMessage="Represents the SPSite to be evaluated" ,Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
[Alias ('URL')]
[String[]]$Site,

[Parameter(HelpMessage="Represents the check-in comment that will be recorded for all files that are checked in" ,Mandatory=$False)]
[String]$AdminMessage="Checked in by administrator"
)

Process
{
    $ActiveSite = Get-SPSite "$($Site)"
    foreach($Web in $ActiveSite.AllWebs)
    {
        Write-Verbose "Processing web with URL: $($Web.url)"
        $Lists = $web.lists | Where-Object {$_ -is [Microsoft.SharePoint.SPDocumentLibrary]}
        foreach($list in $Lists)
        {
            Write-Verbose "Calling Get-CheckedOutFilesInList Cmdlet for list with title:  $($List.title)"
            $CheckedOutFiles = Get-CheckedOutFilesInList -List $list
            foreach($key in $CheckedOutFiles.keys)
            {
                try
                {
                $list.GetItemById(
                $CheckedOutFiles[$key].id).file.CheckIn($AdminMessage)
                Write-Verbose "checked in file with URL $($CheckedOutFiles[$key].url)"
                }
                catch
                {
                    Write-Verbose "Error occurred processing item with ID $($Checkedoutfiles[$key].id)"
                }
            }
        }
        $web.dispose()
    }

}

End
{

}

}
