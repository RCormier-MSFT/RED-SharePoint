<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will perform a system update of all items in the list referenced, which will ensure all list items respect the list version configuration
#>
function Save-SPLibraryVersionConfiguration
{
    param(
    [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
    [Microsoft.SharePoint.SPList]$List
    )

    foreach($Item in $List.Items)
    {
        $Item.SystemUpdate($false)
    }
}
