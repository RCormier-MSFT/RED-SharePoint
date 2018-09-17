<#
Author:Roger Cormier
Company:Microsoft
Description: This cmdlet will remove all SharePoint user profiles from your user profile service application if they match the supplied domain prefix
#>

function Remove-AllDomainUserProfiles
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, position=0)]
    [String]$DomainPrefix,
    [parameter(Mandatory=$True, position=0)]
    [URI]$MySiteHostURL
    )

    Try
    {
        $MySiteHost = Get-SPSite $MySiteHostURL.OriginalString
    }
    catch
    {
        Write-Error "Could not retrieve SharePoint site at URL `'$($MySiteHostURL.OriginalString)`'"
        exit
    }

    $ServiceContext = Get-SPServiceContext $MySiteHost
    $MySiteHost.dispose()
    $upm = new-object Microsoft.Office.Server.UserProfiles.UserProfileManager($serviceContext)
    $UserProfiles = $upm.getenumerator()| Where-Object {$_.accountname -like "$($DomainPrefix)\*"}
    foreach($User in $UserProfiles)
    {
        Try
        {
            Write-Verbose "removing user profile for user $($User.AcountName)"
            $upm.RemoveUserProfile($user.AccountName)
            Write-Verbose "user profile for user `'$($User.AccountName)`' has been removed"
        }
        catch
        {
            Write-Error "cound not remove user profile for user `'$($User.AccountName)`'"
        }
    }
}
