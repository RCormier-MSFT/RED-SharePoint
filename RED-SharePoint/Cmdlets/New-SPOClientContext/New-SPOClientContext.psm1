<#
.SYNOPSIS

Establishes a new client context with SharePoint Online Tenant

.DESCRIPTION

The New-SPOClientContext (RED-SharePoint) cmdlet allow you to establish a connection to a 
SharePoint Onlinte site.

.PARAMETER SiteUri

This is mandatory and specifies the SharePoint Online site with which the 
connection will be made.

.PARAMETER Credential

This provides the credential that has access to the site.

.EXAMPLE 

New-SPOClientContext -SiteUri https://example.sharpoint.com/sites/csomtest -Credential (Get-Credential)

.NOTES


#>

Function New-SPOClientContext
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Uri]$SiteUri,
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]$Credential
    )
    try
    {
        $clientContext = $null
        $clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUri.AbsoluteURI.ToString())
        $clientContext.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credential.UserName, $Credential.Password)
        $clientContext.ExecuteQuery()
    }
    catch
    {
        Write-Error -Message "Error creating client context. Exception: $($_.Exception)"
        return $null
    }
    return $clientContext

}