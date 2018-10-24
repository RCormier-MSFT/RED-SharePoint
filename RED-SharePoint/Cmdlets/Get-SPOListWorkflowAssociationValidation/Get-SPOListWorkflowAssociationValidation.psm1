Function Get-SPOListWorkflowAssociationValidation
{
    [cmdletbinding()]
    param
    (
        [parameter(Mandatory=$True, position=0)]
        [URI]$SiteURI,
        [parameter(Mandatory=$True, position=1)]
        [String]$ListTitle,
        [parameter(Mandatory=$True, position=2)]
        [System.Management.Automation.PSCredential]$Credential
    )

    $SiteContext = New-SPOClientContext -SiteUri $SiteURI.AbsoluteUri -Credential $Credential
    $SPWeb = $SiteContext.Web
    $SiteContext.Load($SPWeb)
    $SPList = $SiteContext.Web.Lists.GetByTitle($ListTitle)
    $SiteContext.Load($SPList)
    $SiteContext.ExecuteQuery()
    $WorkflowServicesManager = Get-SPOWorkflowServicesManager -Web $SiteContext.Web
    $ListWorkflowCount = (Get-SPOListWorkflowAssociations -List $SPList -WorkflowServicesManager $WorkflowServicesManager -SiteContext $SiteContext).count
    Return $ListWorkflowCount
}