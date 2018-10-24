if(!(Get-Module "SharePointPnPPowerShellOnline" -ListAvailable))
{
    Install-Module "SharePointPnPPowerShellOnline"
}
Import-Module "SharePointPnPPowerShellOnline"