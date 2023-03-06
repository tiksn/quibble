@{
	# Script module or binary module file associated with this manifest
	RootModule        = 'quibble.psm1'
	
	# Version number of this module.
	ModuleVersion     = '1.2.1'
	
	# ID used to uniquely identify this module
	GUID              = 'bf172dfc-3753-4f6f-bfe1-452a87cbaf4e'
	
	# Author of this module
	Author            = 'Tigran TIKSN Torosyan'
	
	# Company or vendor of this module
	CompanyName       = 'TIKSN Lab'
	
	# Copyright statement for this module
	Copyright         = 'Copyright (c) 2022 Tigran TIKSN Torosyan'
	
	# Description of the functionality provided by this module
	Description       = 'Sync Microsoft To Do and Habitica tasks'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules   = @(
		@{ ModuleName = 'PSFramework'; RequiredVersion = '1.7.270' },
		@{ ModuleName = 'Microsoft.Graph.Authentication'; RequiredVersion = '1.23.0' },
		@{ ModuleName = 'Microsoft.Graph.Users'; RequiredVersion = '1.23.0' },
		@{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' },
		@{ ModuleName = 'Habitica'; RequiredVersion = '1.2.0' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\quibble.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\quibble.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\quibble.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		'Sync-QuibbleTask'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport   = ''
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
	AliasesToExport   = ''
	
	# List of all modules packaged with this module
	ModuleList        = @()
	
	# List of all files packaged with this module
	FileList          = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData       = @{
		
		#Support for PowerShellGet galleries.
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
}