<#
.SYNOPSIS

This cmdlet will return information about an SPList that will be important in determining the success level of a migration to SharePoint Online

.DESCRIPTION

The Get-SPOListMigrationValidation (RED-SharePoint) cmdlet takes an object where 'Type of Entry' property is a List. It will connect to the list using PNPOnline PowerShell to compare source and destination list information (item count, workflow associations if the list if found

.PARAMETER Entry

Takes a object from a source manifest .JSON file

.PARAMETER Credential

Takes a PSCredential to access SharePoint Online


.EXAMPLE 

$OjbectEntry | Get-SPOListMigrationValidation -Credential $Credential

.NOTES
Author: Roger Cormier
Company: Microsoft
#>

Function Get-SPOListMigrationValidation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$True, position=0)]
    [System.Object[]]$Entry,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
    )

    Write-Host "Processing list $($Entry.'List Title')" -ForegroundColor Cyan
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
    try
    {
        if(Get-PnPConnection -ErrorAction SilentlyContinue)
        {
            if(![String]::IsNullOrEmpty((Get-PnPList -Identity $Entry.'List Title' | Select-Object -ExpandProperty Title -ErrorAction SilentlyContinue)))
            {
                $ListEntry = New-Object System.Object
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "List"
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Source Web URL" -Value $entry.'Web URL'
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Destination Web URL" -Value ($Entry.'Web URL').Replace($entry.'Source Site URL', $entry.'Destination Site URL'.trimend("/"))
                $ListEntry | Add-Member -MemberType NoteProperty -name "List Title" -Value $entry.'List Title'
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Source List Item Count" -value $entry.'Number of Items'
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Destination List Item Count" -Value (Get-PnPList -Identity $entry.'List Title').Itemcount
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Source List Workflow Associations" -Value $Entry."Workflows Associated"
                $ListEntry | Add-Member -MemberType NoteProperty -name "Destination List Workflow Associations" -Value ($Entry | Get-SPOListWorkflowAssociationValidation -Credential $Credential)
                if($ListEntry."Source List Item Count" -eq $ListEntry."Destination List Item Count")
                {
                    $ListEntry | Add-Member -MemberType NoteProperty -Name "List Item Count Matching" -Value "True"
                }
                else
                {
                    $ListEntry | Add-Member -MemberType NoteProperty -Name "List Item Count Matching" -Value "False"
                }

                if($ListEntry."Source List Workflow Associations" -eq $listEntry."Destination List Workflow Associations")
                {
                    $ListEntry | Add-Member -MemberType NoteProperty -name "List Workflow Associations Matching" -value "True"
                }
                else
                {
                    $ListEntry | Add-Member -MemberType NoteProperty -name "List Workflow Associations Matching" -value "False"
                }

                return $ListEntry
            }
            else
            {
                Write-Host "Could not find list `'$($Entry.'List Title')`' in web `'$(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.Trimend("/")))`'" -ForegroundColor Yellow
                $ListEntry = New-Object System.Object
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Type of Entry" -Value "List"
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Source Web URL" -Value $entry.'Web URL'
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Destination Web URL" -Value ($Entry.'Web URL').Replace($entry.'Source Site URL', $entry.'Destination Site URL'.trimend("/"))
                $ListEntry | Add-Member -MemberType NoteProperty -name "List Title" -Value $entry.'List Title'
                $ListEntry | Add-Member -MemberType NoteProperty -Name "List Not Found" -value "True"
                $ListEntry | Add-Member -MemberType NoteProperty -Name "Source List Workflow Associations" -Value $Entry."Workflow Associations"
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