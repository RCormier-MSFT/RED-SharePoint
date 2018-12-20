if(!(Get-module ActiveDirectory -ListAvailable -ErrorAction SilentlyContinue))
{
    if ((Get-WmiObject Win32_OperatingSystem).caption -like "Microsoft Windows Server 2008 R2*")
    {
        Import-Module ServerManager
        Add-WindowsFeature RSAT-AD-PowerShell
    }
}
Import-Module ActiveDirectory -ErrorAction SilentlyContinue