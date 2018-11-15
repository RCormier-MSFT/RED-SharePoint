if(!(Get-Module "SharePointPnPPowerShellOnline" -ListAvailable))
{
    Install-Module "SharePointPnPPowerShellOnline" -ErrorAction SilentlyContinue
}
Import-Module "SharePointPnPPowerShellOnline" -ErrorAction SilentlyContinue