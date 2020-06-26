function Compress-ScriptsToModule {
    param (
        # The project name
		[string]$ProjectName,
        # The project folder
		[string]$ProjectFolder,
		# The module or script file name, e.g. $projectName.psm1 or $projectName.ps1
		[string]$ModuleName,
		# The build configuration
		[string]$Configuration
    )
	$projFile = "$ProjectFolder\$ProjectName.pssproj"
	$scriptsFolder = "$ProjectFolder\Scripts"
	$outputPath = "$ProjectFolder\bin"
	if ($Configuration) {
		$outputPath += "\$Configuration"
	}

	[string]$body
	if (Test-Path $projFile)
	{
		[xml]$proj = Get-Content $projFile
		$body = Get-ProjectFunctionText -proj $proj -ModuleName $ModuleName
	} elseif (Test-Path $scriptsFolder) {
		$body = Merge-Scripts -Path $scriptsFolder
	} else {
		throw "Unable to find Scripts folder or project file for $ModuleName"
	}
	$moduleTemplate = "$ProjectFolder\$ModuleName"
	$moduleFile = "$outputPath\$ModuleName"

	if (Test-Path $outputPath) {
		Remove-Item -Path $outputPath -Recurse -Force
	}

	if (-not (Test-Path $outputPath)) {
		mkdir $outputPath | Out-Null
	}
	if (Test-Path $moduleTemplate) {
		[string]$moduleBody = Get-Content $moduleTemplate | Out-String
	} else {
		[string]$moduleBody = ''
	}
	if ($moduleBody.Contains('## <Scripts> ##')) {
		$moduleBody.Replace('## <Scripts> ##', $body) | Set-Content $moduleFile
	} else {
		"$moduleBody
$body".Trim() | Set-Content $moduleFile -Force
	}
}