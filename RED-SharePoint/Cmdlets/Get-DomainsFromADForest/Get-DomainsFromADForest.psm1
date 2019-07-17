function Get-DomainsFromADForest
{
    [cmdletbinding()]
    param(
    [Parameter(mandatory=$False, position=0, HelpMessage="Path where the Output file should be created")]
    [URI]$OutputDirectory
    )

    $AllDomainInformation = New-Object System.Collections.Arraylist
    [Array]$AllDomains = (Get-ADForest).Domains
    foreach($Domain in $AllDomains)
    {
        $DomainInformation = New-Object System.Object
        $DomainInformation | Add-Member -MemberType NoteProperty -Name DomainFQDN -Value "$($Domain.tostring().tolower())"
        $DomainInformation | Add-Member -MemberType NoteProperty -Name DomainSID -value "$((Get-ADDomain $Domain.ToString().tolower()).DomainSID.Value)"
        $AllDomainInformation.Add($DomainInformation) | Out-Null
        Remove-Variable -name DomainInformation
    }

    if(-not ([String]::IsNullOrEmpty($OutputDirectory)))
    {
        if(-not (test-path $OutputDirectory))
        {
            if($OutputDirectory.LocalPath.Substring($OutputDirectory.LocalPath.LastIndexOf("\")+1).contains("."))
            {
                $OutputDirectory = Split-Path -Parent $OutputDirectory.LocalPath
            }
            $OutputFile = Join-Path $OutputDirectory.LocalPath "\DomainsInForest_$((Get-ADForest).name.replace(".","_")).csv"
            $AllDomainInformation | ConvertTo-Csv -NoTypeInformation | Out-File $OutputFile
        }
    }
    else
    {
        Return $AllDomainInformation
    }


}