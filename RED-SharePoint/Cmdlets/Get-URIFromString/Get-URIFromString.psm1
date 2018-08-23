<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will create a URI based on a relative or absolute path
#>

function Get-URIFromString
{
    [cmdletbinding()]
    param(
        [parameter(mandatory=$True, position=0, ValueFromPipeline=$True)]
        [String]$InputURI
    )
    [URI]$OutputURI = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InputURI)
    Return $OutputURI
}