if(!(Get-Module Microsoft.Online.SharePoint.PowerShell -ListAvailable))
{
    Install-Module Microsoft.Online.SharePoint.PowerShell -ErrorAction SilentlyContinue
}
Import-Module Microsoft.Online.SharePoint.PowerShell -ErrorAction SilentlyContinue