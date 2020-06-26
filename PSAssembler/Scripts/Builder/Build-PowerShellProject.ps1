function Build-PowerShellProject {
	param (
		[string]$Configuration,
		[string]$SolutionFolder,
		[string]$ProjectName,
		[string]$ProjectFolder,
		# Check severity
		[ValidateSet('None', 'Strict')]
		[string]$Check = 'None'
	)
	if ($PSVersionTable.PSEdition -eq 'Desktop') {
		$PSDefaultParameterValues['Out-File:Encoding'] = 'UTF8'
	} elseif ($PSVersionTable.PSEdition -eq 'Core') {
		$PSDefaultParameterValues['Out-File:Encoding'] = 'UTF8BOM'
	}
	$buildConfigPath = "$ProjectFolder\BuildConfig.psd1"
	[string[]]$packageFolders = $()
	if (Test-Path $buildConfigPath) {
		$config = Import-PowerShellDataFile -Path $buildConfigPath
		$projectName = if ($ProjectName) { $ProjectName } else { $config.ProjectName }
		$packageSubfolder = $config.PackageFolder
		$packageFolders += "$SolutionFolder\$packageSubfolder"
	}
	if ($packageFolders.Count -eq 0) {
		$buildToolsConfigPath = "$SolutionFolder\BuildTools\BuildTools.config"
		if (Test-Path $buildToolsConfigPath) {
			[xml]$config = Get-Content $buildToolsConfigPath
			$config.tools.nuget.targetFolders.targetFolder |
				Where-Object -Property buildTarget -EQ true |
				ForEach-Object {
					$packageSubFolder += $_.name
					$packageFolders += "$SolutionFolder\$packageSubfolder"
				}
		}
	}
	$outputFolder = Get-OutputPath -ProjectFolder $projectFolder -Configuration $Configuration

	if (Test-Path $outputFolder) {
		Remove-Item $outputFolder\* -Force -Recurse
	} else {
		mkdir $outputFolder | Out-Null
	}

	Build-PSProject `
		-BuildConfigPath $buildConfigPath `
		-Configuration $Configuration `
		-ProjectName $ProjectName `
		-ProjectFolder $ProjectFolder `
		-Check $Check

	if (Test-Path $ProjectFolder\$ProjectName.psd1) {
		Copy-Item $ProjectFolder\$ProjectName.psd1 $outputFolder
	}
	$packageFolders | Where-Object { $_ } | ForEach-Object {
		$PackageFolder = $_
		if (-not (Test-Path $PackageFolder)) {
			mkdir $PackageFolder | Out-Null
		}
		Copy-Item $outputFolder\* $PackageFolder -Recurse -Force
	}
}