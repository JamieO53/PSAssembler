function Build-PSProject {
	param (
		# The location of the configuration for the the PowerShell project build
		[string]$BuildConfigPath,
		# The build configuration
		[string]$Configuration = '',
		# The project name
		[string]$ProjectName,
		# The project folder
		[string]$ProjectFolder,
		# Check severity
		[ValidateSet('None', 'Strict')]
		[string]$Check = 'None'
	)
	[string]$outputFolder = Get-OutputPath -ProjectFolder $projectFolder -Configuration $Configuration
	[bool]$isModule = -not (Test-Path $projectFolder\$projectName.ps1)
	[string]$ModuleName = if ($isModule) { "$projectName.psm1" } else { "$projectName.ps1" }
	[string]$MandateName = "$projectName.psd1"
	Compress-ScriptsToModule -ProjectName $projectName -ProjectFolder $projectFolder -ModuleName $ModuleName -Configuration $Configuration

	if (Test-Path $projectFolder\$projectName.psd1) {
		Copy-Item $projectFolder\$projectName.psd1 $outputFolder
	}

	if ($Check -eq "Strict") {
		Confirm-Script -Path $outputFolder\$ModuleName
	}

	if ($BuildConfigPath -and (Test-Path $BuildConfigPath)) {
		$cfg = Import-PowerShellDataFile $BuildConfigPath
		$extensionDir = ''
		if ($cfg.extensions.folder) {
			$extensionDir = "$SolutionDir\$($cfg.extensions.folder)"
			if (-not (Test-Path $extensionDir)) {
				$extensionDir = ''
			}
		}
		$cfgPath = @{}
		$cfg.dependencies | ForEach-Object {
			$dependecyOutputFolder = Get-OutputPath -ProjectFolder $SolutionDir\$_ -Configuration $Configuration
			$cfgPath.Add($_, "$dependecyOutputFolder\*")
		}
		if ($extensionDir) {
			$cfg.extensions | ForEach-Object {
				$extensionOutputFolder = Get-OutputPath -ProjectFolder $extensionDir\$_ -Configuration $Configuration
				$cfgPath.Add($_, "$extensionOutputFolder\*")
			}
		}

		$cfgPath.Keys | ForEach-Object {
			$name = $_
			$path = $cfgPath[$name]
			if (Test-Path $path) {
				Copy-Item $path $outputFolder
			}
		}
		$cfg.Dependents | ForEach-Object {
			$depProjectFolder = "$SolutionDir\$_"
			$depOutputFolder = Get-OutputPath -ProjectFolder $depProjectFolder -Configuration $Configuration
			if (Test-Path $depOutputFolder) {
				Copy-Item $outputFolder\* $depOutputFolder
			}
		}
	}
	if ($isModule -and (Test-Path $projectFolder\$MandateName)) {
		Copy-Item $projectFolder\$MandateName $outputFolder
	}
}

