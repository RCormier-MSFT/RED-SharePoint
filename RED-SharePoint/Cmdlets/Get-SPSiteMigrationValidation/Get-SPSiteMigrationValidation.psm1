function Get-SPSiteMigrationValidation
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
        Connect-PnPOnline -url $Entry.'Destination Site URL' -Credentials $Credential | Out-Null
    }
    catch
    {
        Write-host "could not connect to site $($Entry.'Destination Site URL')"
    }
    Try
    {
        if(Get-PnPConnection)
        {
            $SiteEntry = New-Object System.Object
            $SiteEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Site"
            $SiteEntry | Add-Member -MemberType NoteProperty -name "Source Site URL" -value $Entry."Source Site URL"
            $SiteEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -value $Entry."Destination Site URL"
            $SiteEntry | Add-Member -MemberType NoteProperty -Name "Source Number of Webs" -Value $Entry."Number of Webs"
            $SiteEntry | Add-Member -MemberType NoteProperty -name "Destination Number of Webs" -Value ((Get-PnPSubWebs -Recurse).count+1)
            if($SiteEntry."Source Number Of Webs" -eq $SiteEntry."Destination Number of Webs")
            {
                $SiteEntry | Add-Member -MemberType NoteProperty -name "Number of Webs Matching" -value "True"
            }
            else
            {
                $SiteEntry | Add-Member -MemberType NoteProperty -name "Number of Webs Matching" -value "False"
            }
            Disconnect-PnPOnline
            Return $SiteEntry

        }
        else
        {
            Write-Host "No connection to site $($Entry.'Destination Site URL')"
        }
    }
    catch
    {
        write-host "Could not process site $($Entry.'Destination Site URL')"
    }
}