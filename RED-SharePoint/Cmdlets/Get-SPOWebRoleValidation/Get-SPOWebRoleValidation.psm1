Function Get-SPOWebRoleValidation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$True, position=0)]
    [System.Object[]]$Entry,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
    )

    Try
    {
        try
        {
            try
            {
                Get-PnPConnection | Out-Null
                if(-not ((Get-PnPConnection).url.trimend("/") -eq $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/")))))
                {
                    Disconnect-PnPOnline
                    Connect-PnPOnline -Url $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/"))) -Credentials $Credential | Out-Null
                }
            }
            catch
            {
                Connect-PnPOnline -Url $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/"))) -Credentials $Credential | Out-Null
            }
        }
        catch
        {
            write-host "Could not connect to web $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/")))"
        }
        $WebRole = Get-PnPRoleDefinition -Identity $Entry.'Role Name' -ErrorAction SilentlyContinue
        $WebRoleEntry = New-Object System.Object
        $WebRoleEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Role"
        $WebRoleEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $Entry.'Source Site URL'
        $WebRoleEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $Entry.'Destination Site URL'
        $WebRoleEntry | Add-Member -MemberType NoteProperty -Name "Role Name" -Value $Entry.'Role Name'
        if($WebRole)
        {
            $WebRoleEntry | Add-Member -MemberType NoteProperty -Name "Exists in Destination Site" -Value "True"
        }
        else
        {
            $WebRoleEntry | Add-Member -MemberType NoteProperty -Name "Exists in Destination Site" -Value "False"
        }
        Return $WebRoleEntry
    }
    catch
    {
        Write-Host "Could not connect to site $(($Entry.'Web URL').Replace($Entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/"))) using credential for user $($Credential.UserName)"
    }
}