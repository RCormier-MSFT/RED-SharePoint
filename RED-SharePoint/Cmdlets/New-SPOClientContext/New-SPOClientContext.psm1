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