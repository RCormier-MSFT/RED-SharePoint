function Get-SPOListWorkflowAssociations
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [Microsoft.SharePoint.Client.List]$List,
        [Parameter(Mandatory=$True)]
        [Microsoft.SharePoint.Client.ClientContext]$SiteContext,
        [Parameter(Mandatory=$true)]
        [Microsoft.SharePoint.Client.WorkflowServices.WorkflowServicesManager]$WorkflowServicesManager
    )

    $WorkflowAssociationSummary = New-Object System.Collections.Arraylist
    if(-not $list.Hidden -and $list.ItemCount -gt 0)
    {
        # 2013/WFM Associations
        if($workflowServicesManager.IsConnected)
        {
            $workflowSubscriptionService = $workflowServicesManager.GetWorkflowSubscriptionService()
            $workflowAssociations = $workflowSubscriptionService.EnumerateSubscriptionsByList($List.Id)
            $SiteContext.Load($workflowAssociations)
            $SiteContext.ExecuteQuery()
            if($workflowAssociations -and $workflowAssociations.Count -gt 0)
            {
                foreach($association in $workflowAssociations)
                {
                    $WorkflowInstance = New-Object System.Object
                    $WorkflowInstance | Add-Member -MemberType NoteProperty -Name "Site" -Value "$($SiteContext.Site.Url)"
                    $WorkflowInstance | Add-Member -MemberType NoteProperty -Name "Web" -Value "$($SiteContext.Web.url)"
                    $WorkflowInstance | Add-Member -MemberType NoteProperty -Name "List" -Value "$($List.Title)"
                    $WorkflowInstance | Add-Member -MemberType NoteProperty -Name "WorkflowAssociation" -Value "$($Association.name)"
                    $WorkflowInstance | Add-Member -MemberType NoteProperty -Name "WorkflowVersion" -Value "2013"
                    $WorkflowAssociationSummary.Add($WorkflowInstance) | Out-Null
                    Remove-Variable -Name "WorkflowInstance"
                }
            }
        }
        # 2010 Associations
        $SiteContext.Load($list.WorkflowAssociations)
        $SiteContext.ExecuteQuery()
        foreach($association in $list.WorkflowAssociations)
        {
            $WorkflowInstance = New-Object System.Object
            $WorkflowInstance | Add-Member -MemberType NoteProperty -Name "Site" -Value "$($SiteContext.Site.Url)"
            $WorkflowInstance | Add-Member -MemberType NoteProperty -Name "Web" -Value "$($SiteContext.Web.url)"
            $WorkflowInstance | Add-Member -MemberType NoteProperty -Name "List" -Value "$($List.Title)"
            $WorkflowInstance | Add-Member -MemberType NoteProperty -Name "WorkflowAssociation" -Value "$($Association.name)"
            $WorkflowInstance | Add-Member -MemberType NoteProperty -Name "WorkflowVersion" -Value "2010"
            $WorkflowAssociationSummary.Add($WorkflowInstance) | Out-Null
            Remove-Variable -Name "WorkflowInstance"
        }
    }
    Return $WorkflowAssociationSummary
}