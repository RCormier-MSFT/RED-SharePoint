if( -not (get-package "Microsoft.SharePointOnline.CSOM" -ErrorAction SilentlyContinue))
{
    Install-Package -Name "Microsoft.SharePointOnline.CSOM" -Source "https://www.nuget.org/api/v2" -Force
    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::ExtractToDirectory((Get-Package "Microsoft.SharePointOnline.CSOM" | Select-Object -ExpandProperty Source), ("C:\program files\SharePointOnlineCSOM\"))
}
Add-Type -Path "C:\Program Files\SharePointOnlineCSOM\lib\net45\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\SharePointOnlineCSOM\lib\net45\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\SharePointOnlineCSOM\lib\net45\Microsoft.SharePoint.Client.WorkflowServices.dll"
