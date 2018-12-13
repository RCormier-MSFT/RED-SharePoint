function Get-SPOWebMigrationValidation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$True, position=0)]
    [System.Object[]]$Entry,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential,
    [parameter(Mandatory=$False, position=2, HelpMessage="Use the -IncludeHiddenLists switch to include hidden lists in the report")]
    [switch]$IncludeHiddenLists
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
            if($Entry."Web Parts on Page" -eq $WebpartCount)
            {
                $WebEntry | add-member -MemberType NoteProperty -name "Number of Web Parts Matching" -value "True"
            }
            else
            {
                $WebEntry | add-member -MemberType NoteProperty -name "Number of Web Parts Matching" -value "False"
            }
            $WebEntry | Add-Member -MemberType NoteProperty -name "Source Visible Web Parts on Page" -value $Entry."Visible Web Parts on Page"
            if($OpenWebPartCount = (Get-PnPWebPart -ServerRelativePageUrl (Get-PnPHomePage) | ? {$_.webpart.isclosed -eq $False}).count)
            {
                $WebEntry | Add-Member -MemberType NoteProperty -Name "Destination Number of visible webparts" -Value $OpenWebPartCount
            }
            else
            {
                $WebEntry | Add-Member -MemberType NoteProperty -Name "Destination Number of visible webparts" -Value "0"
            }
            if($Entry."Visible Web Parts on Page" -eq $OpenWebPartCount)
            {
                $WebEntry | add-member -MemberType NoteProperty -name "Number of Visible Web Parts Matching" -value "True"
            }
            else
            {
                $WebEntry | add-member -MemberType NoteProperty -name "Number of Visible Web Parts Matching" -value "False"
            }
            $WebEntry | Add-Member -MemberType NoteProperty -Name "Source Number of Lists" -value $entry."Number of Lists"
            if($IncludeHidddenLists)
            {
                $WebEntry | Add-Member -MemberType NoteProperty -name "Destination Number of Lists" -Value (Get-PnPList).count
            }
            else
            {
                $WebEntry | Add-Member -MemberType NoteProperty -name "Destination Number of Lists" -Value (Get-PnPList | Where-Object {-not $_.hidden}).count
            }

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