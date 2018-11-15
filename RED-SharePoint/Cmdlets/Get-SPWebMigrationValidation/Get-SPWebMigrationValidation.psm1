function Get-SPWebMigrationValidation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$True, position=0)]
    [System.Object[]]$Entry,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
    )

    Write-Host "Connecting to web $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/")))"
    try
    {
        Connect-PnPOnline -Url $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/"))) -Credentials $Credential | Out-Null
    }
    catch
    {
        write-host "$(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/")))"
    }
    Try
    {
        if(Get-PnPConnection)
        {
            $WebEntry = New-Object System.Object
            $WebEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "Web"
            $WebEntry | Add-Member -MemberType NoteProperty -Name "Source Web URL" -Value $Entry."Web URL"
            $WebEntry | Add-Member -MemberType NoteProperty -Name "Destination Web URL" -Value $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/")))
            $WebEntry | Add-Member -MemberType NoteProperty -Name "Source Web Title" -value $Entry.'Web Title'
            $WebEntry | Add-Member -MemberType NoteProperty -Name "Destination Web Title" -value (Get-PnPWeb).title
            if($Entry."Web Title" -eq $WebEntry."Destination Web Title")
            {
                $WebEntry | Add-Member -MemberType NoteProperty -name "Web Title Matching" -value "True"
            }
            else
            {
                $WebEntry | Add-Member -MemberType NoteProperty -name "Web Title Matching" -value "False"
            }
            $WebEntry | Add-Member -MemberType NoteProperty -name "Source Web Parts on Page" -value $Entry."Web Parts on Page"
            if($WebpartCount = (Get-PnPWebPart -ServerRelativePageUrl (Get-PnPHomePage) -ErrorAction SilentlyContinue).count)
            {
                $WebEntry | add-member -MemberType NoteProperty -Name "Destination Web Parts on Page" -Value $WebpartCount
            }
            else
            {
                $WebEntry | add-member -MemberType NoteProperty -Name "Destination Web Parts on Page" -Value "0"
            }
            if($WebEntry."Source Web Parts on Page" -eq $WebEntry."Destination Web Parts on Page")
            {
                $WebEntry | add-member -MemberType NoteProperty -name "Number of Web Parts Matching" -value "True"
            }
            else
            {
                $WebEntry | add-member -MemberType NoteProperty -name "Number of Web Parts Matching" -value "True"
            }
            $WebEntry | Add-Member -MemberType NoteProperty -Name "Source Number of Lists" -value $entry."Number of Lists"
            $WebEntry | Add-Member -MemberType NoteProperty -name "Destination Number of Lists" -Value (Get-PnPList).count
            if($entry."Number of Lists" -eq $WebEntry."Destination Number of Lists")
            {
                $WebEntry | add-member -MemberType NoteProperty -name "Number of Lists Matching" -Value "True"
            }
            else
            {
                $WebEntry | add-member -MemberType NoteProperty -name "Number of Lists Matching" -Value "False"
            }

            Disconnect-PnPOnline
            Return $WebEntry

        }
        else
        {
            Write-Host "No Connection to web $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/")))"
        }
    }
    catch
    {
        Write-Host "$(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/")))"
    }
}