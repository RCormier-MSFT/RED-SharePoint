Function Get-SPListMigrationValidation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$True, position=0)]
    [System.Object[]]$Entry,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
    )

    try
    {
        Connect-PnPOnline -Url $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL')) -Credentials $Credential | Out-Null
    }
    catch
    {
        write-host "Could not connect to web $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'))"
    }
    try
    {
        if(Get-PnPConnection)
        {
            if(Get-PnPList -Identity $entry.'List Title')
            {
                $ListEntry = New-Object System.Object
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "List"
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Source Web URL" -Value $entry.'Web URL'
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Destination Web URL" -Value ($Entry.'Web URL').Replace($entry.'Source Site URL', $entry.'Destination Site URL')
                $ListEntry | Add-Member -MemberType NoteProperty -name "List Title" -Value $entry.'List Title'
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Source List Item Count" -value $entry.'Number of Items'
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Destination List Item Count" -Value (Get-PnPList -Identity $entry.'List Title').count
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Source List Workflow Associations" -Value $Entry."Workflow Associations"
                $ListEntry | Add-Member -MemberType NoteProperty -name "Destination List Workflow Associations" -Value
                if($ListEntry."Source List Item Count" -eq $ListEntry."Destination List Item Count")
                {
                    $ListEntry | Add-Member -MemberType NoteProperty -Name "List Item Count Matching" -Value "True"
                }
                else
                {
                    $ListEntry | Add-Member -MemberType NoteProperty -Name "List Item Count Matching" -Value "False"
                }
                Disconnect-PnPOnline
                return $ListEntry
            }
            else
            {
                Disconnect-PnPOnline
            }

        }
        else
        {
            Write-Host "Could not process list $($Entry.'List Title') due to no connection to site or web"
        }
    }
    catch
    {
        write-host "Could not process List $($entry.'List Title')"
    }

}