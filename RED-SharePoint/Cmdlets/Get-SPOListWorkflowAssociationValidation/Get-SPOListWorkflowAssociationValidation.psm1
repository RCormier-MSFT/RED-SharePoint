Function Get-SPOListWorkflowAssociationValidation
{
    [cmdletbinding()]
    param(
    [parameter(Mandatory=$True, ValueFromPipeline=$True, position=0)]
    [System.Object[]]$Entry,
    [parameter(Mandatory=$True, position=1)]
    [System.Management.Automation.PSCredential]$Credential
    )

    $SiteContext = New-SPOClientContext -SiteUri $(($Entry.'Web URL').Replace($entry.'Source Site URL', $Entry.'Destination Site URL'.trimend("/"))) -Credential $Credential
    $SPWeb = $SiteContext.Web
    $SiteContext.Load($SPWeb)
    $SPList = $SiteContext.Web.Lists.GetByTitle($Entry.'List Title')
    $SiteContext.Load($SPList)
    $SiteContext.ExecuteQuery()
    $WorkflowServicesManager = Get-SPOWorkflowServicesManager -Web $SiteContext.Web
    $ListWorkflowCount = (Get-SPOListWorkflowAssociations -List $SPList -WorkflowServicesManager $WorkflowServicesManager -SiteContext $SiteContext).count
    Return $ListWorkflowCount

}