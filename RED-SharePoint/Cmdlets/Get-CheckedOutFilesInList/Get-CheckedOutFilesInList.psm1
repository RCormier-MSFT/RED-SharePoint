<#
.SYNOPSIS

This cmdlet returns a list of all checked out files in a site collection


.DESCRIPTION

The Get-CheckedOutFilesInList (RED-SharePoint) cmdlet takes a SharePoint list of type Document Library and returns a list of checked out files.


.PARAMETER List

Specifies the URL of the SharePoint source Site Collection.


.EXAMPLE 

Get-SPList 'http://servername/lists/mylist' | Get-CheckedOutFilesInList 


.EXAMPLE 

$list = Get-SPList 'http://server_name/lists/mylist'
Get-CheckedOutFilesInList -List $list


.NOTES

Author:     Roger Cormier
Company:    Microsoft

#>

function Get-CheckedOutFilesInList
{
    [CmdletBinding()]
    param(
    #SPList Pipebind
    [Parameter(HelpMessage="This represents the binding to an SPList", Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName, ParameterSetName="ListFromPipeline", position=0)]
    [Alias ('Title')]
    [Microsoft.SharePoint.SPList]$List
    )

    Begin
    {
        if($List -isnot [Microsoft.SharePoint.SPDocumentLibrary])
        {
            Write-Verbose "List referenced is not a document library"
            exit
        }
    }

    Process
    {
        $CheckedOutFiles = @{}
        Write-Verbose "Getting checked out files"

        foreach( $File in ($List.Items | Where-Object { $_.file.checkoutstatus -ne "None"}))
        {
            $CheckedOutFiles.Add($File.url, $File)
        }
    }

    End
    {
        Return $CheckedOutFiles
    }

}


