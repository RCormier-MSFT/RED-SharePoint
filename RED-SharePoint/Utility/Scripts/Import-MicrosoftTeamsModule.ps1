if(!(Get-Module MicrosoftTeams -ListAvailable))
{
    Install-Module MicrosoftTeams -ErrorAction SilentlyContinue
}

Import-Module MicrosoftTeams -ErrorAction SilentlyContinue