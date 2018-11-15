Function Get-SPOSitePermissionMasks
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$True, position=0)]
    [URI]$SiteURI,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
    )

    $SPOCreds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credential.UserName, $Credential.Password)
    $PermissionProxyAddress = "$($SiteURI.absoluteURI.TrimEnd("/"))/_vti_bin/Permissions.asmx?wsdl"
    $ProfileServiceProxy = New-WebServiceProxy -Uri $PermissionProxyAddress -UseDefaultCredential False
    $ProfileServiceProxy.Credentials = $SPOCreds
    $AuthenticationCookie = $SPOCreds.GetAuthenticationCookie($SiteURI.AbsoluteUri)
    $CookieContainer = New-Object System.Net.CookieContainer
    $CookieContainer.SetCookies($SiteURI,$AuthenticationCookie)
    $ProfileServiceProxy.CookieContainer = $CookieContainer
    [System.xml.xmlnode]$PermissionsXML = $ProfileServiceProxy.GetPermissionCollection("yxd", "web")
    return $PermissionsXML.Permissions.Permission
}