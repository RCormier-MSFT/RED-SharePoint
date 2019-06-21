#
# Module manifest for module 'RED-SharePoint'
#
# Generated by: Roger Cormier - PFE
#
# Generated on: 03/12/18
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = ''

# Version number of this module.
ModuleVersion = '1.0.0.81'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '15e504cf-b074-4e7e-ac66-217fec4e37ef'

# Author of this module
Author = 'Roger Cormier - PFE'

# Company or vendor of this module
CompanyName = 'Microsoft'

# Copyright statement for this module
Copyright = '(c) 2018 Roger Cormier - PFE. All rights reserved.'

# Description of the functionality provided by this module
Description = 'SharePoint PowerShell Module, Codename: RED'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
#RequiredModules = @({"Module Name= Microsoft.Online.SharePoint.PowerShell"})

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @(".\Utility\Scripts\Import-SharePointOnlineCSOM.ps1",
                     ".\Utility\Scripts\Import-SharePointPNPModule.ps1",
                     ".\Utility\scripts\Import-SharePointPowerShellSnapIn.ps1",
                     ".\Utility\Scripts\Import-SharePointOnlinePowerShellModule.ps1",
                     ".\Utility\Scripts\Import-MicrosoftTeamsModule.ps1",
                     ".\Utility\Scripts\Import-ActiveDirectoryModule.ps1")

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(".\Cmdlets\Compare-SPFeatures\Compare-SPFeatures.psm1",
                ".\Cmdlets\Get-CheckedOutFilesInList\Get-CheckedOutFilesInList.psm1",
                ".\Cmdlets\Get-SMATReportUniqueSites\Get-SMATReportUniqueSites.psm1",
                ".\Cmdlets\Get-SMATReportUniqueUsers\Get-SMATReportUniqueUsers.psm1",
                ".\cmdlets\Get-SPListMigrationManifestInfo\Get-SPListMigrationManifestInfo.psm1",
                ".\cmdlets\Get-SPOListMigrationValidation\Get-SPOListMigrationValidation.psm1",
                ".\cmdlets\Get-SPOListWorkflowAssociations\Get-SPOListWorkflowAssociations.psm1",
                ".\cmdlets\Get-SPOListWorkflowAssociationValidation\Get-SPOListWorkflowAssociationValidation.psm1",
                ".\cmdlets\Get-SPOSitePermissionMasks\Get-SPOSitePermissionMasks.psm1",
                ".\cmdlets\Get-SPOWebGroupMappingValiation\Get-SPOWebGroupMappingValidation.psm1",
                ".\cmdlets\Get-SPOWebGroupValidation\Get-SPOWebGroupValidation.psm1",
                ".\Cmdlets\Get-SPOWebMigrationValidation\Get-SPOWebMigrationValidation.psm1",
                ".\cmdlets\Get-SPOWebRoleValidation\Get-SPOWebRoleValidation.psm1",
                ".\cmdlets\Get-SPOWorkflowServicesManager\Get-SPOWorkflowServicesManager.psm1",
                ".\cmdlets\Get-SPSiteMigrationManifestInfo\Get-SPSiteMigrationManifestInfo.psm1",
                ".\cmdlets\Get-SPSiteMigrationValidation\Get-SPSiteMigrationValidation.psm1",
                ".\cmdlets\Get-SPWebAssociatedGroupsFromMigrationManifest\Get-SPWebAssociatedGroupsFromMigrationManifest.psm1",
                ".\cmdlets\Get-SPWebGroupsMigrationManifestInfo\Get-SPWebGroupsMigrationManifestInfo.psm1",
                ".\cmdlets\Get-SPWebMigrationManifestInfo\Get-SPWebMigrationManifestInfo.psm1",
                ".\cmdlets\Get-SPWebRolesMigrationManifestInfo\Get-SPWebRolesMigrationManifestInfo.psm1",
                ".\Cmdlets\Get-TeamsInformation\Get-TeamsInformation.psm1",
                ".\cmdlets\Get-UniqueSitesFromSourceSiteMigrationManifest\Get-UniqueSitesFromSourceSiteMigrationManifest.psm1",
                ".\Cmdlets\Get-URIFromString\Get-URIFromString.psm1",
                ".\Cmdlets\Get-WebsWithUniquePermissionsFromMigrationManifest\Get-WebsWithUniquePermissionsFromMigrationManifest.psm1",
                ".\Cmdlets\New-BulkFileCheckIn\New-BulkFileCheckIn.psm1",
                ".\Cmdlets\New-SMATCheckedOutFileSummaryReportBulkCheckIn\New-SMATCheckedOutFileSummaryReportBulkCheckIn.psm1",
                ".\Cmdlets\New-SMATReportCheckedOutFilesEmail\New-SMATReportCheckedOutFilesEmail.psm1",
                ".\Cmdlets\New-SMATReportCheckedOutFilesSummary\New-SMATReportCheckedOutFilesSummary.psm1",
                ".\Cmdlets\New-SMATReportIndividualUserPackage\New-SMATReportIndividualUserPackage.psm1",
                ".\Cmdlets\New-SMATReportSiteOwnerPackage\New-SMATReportSiteOwnerPackage.psm1",
                ".\cmdlets\New-SourceSiteMigrationManifest\New-SourceSiteMigrationManifest.psm1",
                ".\Cmdlets\New-SPCheckedOutFileSummary\New-SPCheckedOutFileSummary.psm1",
                ".\cmdlets\New-SPMigrationManifestValidationSummary\New-SPMigrationManifestValidationSummary.psm1",
                ".\cmdlets\New-SPMigrationValidationReportPackage\New-SPMigrationValidationReportPackage.psm1",
                ".\cmdlets\New-SPOBulkAssociatedGroupsUpdate\New-SPOBulkAssociatedGroupsUpdate.psm1",
                ".\cmdlets\New-SPOClientContext\New-SPOClientContext.psm1",
                ".\cmdlets\New-SPVersionReport\New-SPVersionReport.psm1",
                ".\cmdlets\Remove-AllDomainUserProfiles\Remove-AllDomainUserProfiles.psm1",
                ".\Cmdlets\Rename-SPContentDatabaseServer\Rename-SPContentDatabaseServer.psm1",
                ".\Cmdlets\Save-SPLibraryVersionConfiguration\Save-SPLibraryVersionConfiguration.psm1",
                ".\Cmdlets\Set-SPLibraryVersionConfiguration\Set-SPLibraryVersionConfiguration.psm1",
                ".\Cmdlets\Set-SPOAssociatedGroups\Set-SPOAssociatedGroups.psm1"
                  )

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = '*'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

