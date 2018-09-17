<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet dismount a content database from a web application and then mount a content database with the same name to the same web application.  This cmdlet is to be used when a SQL server has been renamed or replaced.  The database must exist on the 'DestinationSQLServer' supplied
#>

function Rename-SPContentDatabaseToNewDatabaseServer
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0)]
    [String]$SourceSQLServer,
    [parameter(Mandatory=$True, position=1)]
    [URI]$DestinationSQLServer
    )

    if(!(Get-PSSnapin Microsoft.SharePoint.PowerSHell -ErrorAction SilentlyContinue)){Add-PSSnapin Microsoft.SharePoint.PowerShell}

    Write-Verbose "Fetching Content Database where server is `'$($SourceSQLServer)`'"
    $Databases = get-spcontentdatabase | Where-Object {$_.Server -eq $SourceSQLServer}
    Write-Verbose "found $($Databases.Count) databases matching specified criteria"

    foreach($Database in $Databases)
    {
        Write-Verbose "Processing database `'$($Database | Select-Object -ExpandProperty Name)`'"
        Write-Verbose "Extracting web application URL"
        $WebApplication = Get-SPWebApplication ($Database | Select-Object -ExpandProperty "WebApplication" | Select-Object -ExpandProperty URL)
        write-verbose "Web Application URL for this database is `'$($WebApplication)`'"
        Write-Verbose "Dismounting content database `'$($Database | Select-Object -ExpandProperty Name)`' on database server $($Database | Select-Object -ExpandProperty Server) from Web Application"
        Dismount-SPContentDatabase ($Database | Select-Object -ExpandProperty Name) -Confirm:$False
        Write-Verbose "Mounting content database `'$($Database | Select-Object -ExpandProperty Name) from database server `'$($DestinationSQLServer)`'"
        Mount-SPContentDatabase -Name ($Database | Select-Object -ExpandProperty Name) -DatabaseServer $DestinationSQLServer -WebApplication $WebApplication

    }
}