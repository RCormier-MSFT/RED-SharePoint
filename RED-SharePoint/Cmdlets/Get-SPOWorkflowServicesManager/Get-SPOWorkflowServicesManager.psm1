function Get-SPOWorkflowServicesManager
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [Microsoft.SharePoint.Client.Web]$Web
    )

    $WorkflowServicesManager = New-Object Microsoft.SharePoint.Client.WorkflowServices.WorkflowServicesManager($Web.Context, $Web )
    Return $WorkflowServicesManager
}