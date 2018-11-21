Function Get-SPOWebGroupMappingValidation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$True, position=0)]
    [System.Object[]]$Entry,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
    )

    Connect-PnPOnline -Url $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/"))) -Credentials $Credential | Out-Null
    $GroupPermissions = Get-PnPGroupPermissions -Identity $Entry.'Group Name' -ErrorAction SilentlyContinue
    if($GroupPermissions.length -le 0)
    {
        $GroupMappingEntry = New-Object System.Object
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $Entry.'Source Site URL'
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $Entry.'Destination Site URL'
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -name "Web URL" -Value (Get-PnPConnection | Select-Object URL)
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -Name "Group Name" -Value $Entry.'Group Name'
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -name "Missing From Destination Site" -Value 'True'
}
    else
    {
        $GroupMappingEntry = New-Object System.Object
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $Entry.'Source Site URL'
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $Entry.'Destination Site URL'
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -name "Web URL" -Value (Get-PnPConnection | Select-Object URL)
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -Name "Group Name" -Value $Entry.'Group Name'
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -name "Source Roles Assigned" -Value $Entry.'Roles Assigned'
        $GroupMappingEntry | Add-Member -MemberType NoteProperty -Name "Destination Roles Assigned" -Value ([String]::Join(",", ($GroupPermissions | Select-Object -ExpandProperty Name)))
        if($entry.'Roles Assigned' -match [String]::Join(",",($GroupPermissions | Select-Object -ExpandProperty Name)))
        {
            $GroupMappingEntry | Add-Member -MemberType NoteProperty -Name "Source and Destination Mappings Match" -Value "True"
        }
        else
        {
            $GroupMappingEntry | Add-Member -MemberType NoteProperty -Name "Source and Destination Mappings Match" -Value "False"
        }
    }

    Return $GroupMappingEntry
}