Function Get-SPOWebGroupValidation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$True, position=0)]
    [System.Object[]]$Entry,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
    )

    Connect-PnPOnline -Url $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/"))) -Credentials $Credential | Out-Null
    $WebGroup = Get-PnPGroup -Identity $Entry.'Group Name' -ErrorAction SilentlyContinue
    $WebGroupEntry = New-Object System.Object
    $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Source Site URL" -Value $Entry.'Source Site URL'
    $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Destination Site URL" -Value $Entry.'Destination Site URL'
    $WebGroupEntry | Add-Member -MemberType NoteProperty -name "Web URL" -Value (Get-PnPConnection | Select-Object URL)
    $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Group Name" -value $Entry.'Group Name'
    if($WebGroup)
    {
        $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Exists in Destination Site" -Value "True"
    }
    else
    {
        $WebGroupEntry | Add-Member -MemberType NoteProperty -Name "Exists in Destination Site" -Value "False"
    }


}