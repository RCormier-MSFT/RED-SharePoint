function Get-SPNavigationReport
{
    param(
        [Parameter(mandatory=$True, position=0, HelpMessage="Site Collection URL for which the summary report should be prepared")]
        [URI]$SiteURL,
        [Parameter(mandatory=$True, position=0, HelpMessage = "Which Navigational Elements Should Be Included In this Report?")]
        [ValidateSet("GlobalNavOnly", "QuickLaunchOnly", "GlobalNavAndQuickLaunch")]
        [String]$ReportNodes
    )

    $CurrentSite = get-spsite $SiteURL.AbsoluteUri -ErrorAction SilentlyContinue
    if(-not $CurrentSite)
    {
        write-host $error[0].Exception.Message -ForegroundColor Red
        break
    }

    $NavNodeSummary = New-Object System.Collections.ArrayList

    foreach($Web in $CurrentSite.Allwebs)
    {
        if($PublishingSite = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($Web))
        {
            if($ReportNodes.ToUpper().Contains("GLOBAL"))
            {
                $GlobalNav = $PublishingSite.Navigation.GlobalNavigationNodes
                foreach($Node in $GlobalNav)
                {
                    $NodeInfo = New-Object System.Object
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "Web URL" -Value $Web.URL
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "Type of Node" -Value "Global Navigation"
                    $NodeInfo | Add-Member -MemberType NoteProperty -name "Title" -Value $Node.Title
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "URL" -value $Node.Url
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "ID" -Value $Node.ID
                    if($NavNodeSummary | Where-Object {($_.url -eq $Node.Url) -and ($_.title -eq $Node.Title) -and ($_.'Web URL' -eq $Web.url)})
                    {
                        $NodeInfo | Add-Member -MemberType NoteProperty -Name "Suspected Duplicate" -Value "True"
                    }
                    else
                    {
                        $NodeInfo | Add-Member -MemberType NoteProperty -Name "Suspected Duplicate" -Value "False"
                    }
                    $NavNodeSummary.Add($NodeInfo) | Out-Null
                
                    foreach($childnode in $node.Children)
                    {
                        $NodeInfo = New-Object System.Object
                        $NodeInfo | Add-Member -MemberType NoteProperty -Name "Web URL" -Value $Web.URL
                        $NodeInfo | Add-Member -MemberType NoteProperty -Name "Type of Node" -Value "Global Navigation"
                        $NodeInfo | Add-Member -MemberType NoteProperty -name "Title" -Value $ChildNode.Title
                        $NodeInfo | Add-Member -MemberType NoteProperty -Name "URL" -value $ChildNode.Url
                        $NodeInfo | Add-Member -MemberType NoteProperty -Name "ID" -Value $ChildNode.ID
                        $NodeInfo | Add-Member -MemberType NoteProperty -Name "Parent ID" -Value $Node.Id
                        if($NavNodeSummary | Where-Object {($_.url -eq $ChildNode.Url) -and ($_.title -eq $ChildNode.Title) -and ($_.'Web URL' -eq $Web.url) -and ($_.'Parent ID' -eq $ChildNode.ParentId)})
                        {
                            $NodeInfo | Add-Member -MemberType NoteProperty -Name "Suspected Duplicate" -Value "True"
                        }
                        else
                        {
                            $NodeInfo | Add-Member -MemberType NoteProperty -Name "Suspected Duplicate" -Value "False"
                        }
                        $NavNodeSummary.Add($NodeInfo) | Out-Null
                    }
                }
            }
            
        }
        if($ReportNodes.ToUpper().Contains("QUICKLAUNCH"))
        {
            $Quicklaunch = $Web.Navigation.QuickLaunch
            foreach($Node in $QuickLaunch)
            {
                $NodeInfo = New-Object System.Object
                $NodeInfo | Add-Member -MemberType NoteProperty -Name "Web URL" -Value $Web.URL
                $NodeInfo | Add-Member -MemberType NoteProperty -Name "Type of Node" -Value "Quick Launch"
                $NodeInfo | Add-Member -MemberType NoteProperty -name "Title" -Value $Node.Title
                $NodeInfo | Add-Member -MemberType NoteProperty -Name "URL" -value $Node.Url
                $NodeInfo | Add-Member -MemberType NoteProperty -Name "ID" -Value $Node.ID
                if($NavNodeSummary | Where-Object {($_.url -eq $Node.Url) -and ($_.title -eq $Node.Title) -and ($_.'Web URL' -eq $Web.url)})
                {
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "Suspected Duplicate" -Value "True"
                }
                else
                {
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "Suspected Duplicate" -Value "False"
                }
                $NavNodeSummary.Add($NodeInfo) | Out-Null
                
                foreach($childnode in $node.Children)
                {
                    $NodeInfo = New-Object System.Object
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "Web URL" -Value $Web.URL
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "Type of Node" -Value "Quick Launch"
                    $NodeInfo | Add-Member -MemberType NoteProperty -name "Title" -Value $ChildNode.Title
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "URL" -value $ChildNode.Url
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "ID" -Value $ChildNode.ID
                    $NodeInfo | Add-Member -MemberType NoteProperty -Name "Parent ID" -Value $Node.Id
                    if($NavNodeSummary | Where-Object {($_.url -eq $ChildNode.Url) -and ($_.title -eq $ChildNode.Title) -and ($_.'Web URL' -eq $Web.url) -and ($_.'Parent ID' -eq $ChildNode.ParentId)})
                    {
                        $NodeInfo | Add-Member -MemberType NoteProperty -Name "Suspected Duplicate" -Value "True"
                    }
                    else
                    {
                        $NodeInfo | Add-Member -MemberType NoteProperty -Name "Suspected Duplicate" -Value "False"
                    }
                    $NavNodeSummary.Add($NodeInfo) | Out-Null
                }
            }
        }
        
    }
    Return $NavNodeSummary
}

