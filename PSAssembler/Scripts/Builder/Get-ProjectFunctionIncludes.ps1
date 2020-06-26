function Get-ProjectFunctionIncludes {
	param (
		[xml]$proj,
		[string]$ModuleName
	)
	$name = $ModuleName # PSScriptAnalyzer warning
	$proj.Project.ItemGroup.Compile.Include |
		Where-Object {
			[string]$path = $_
			$path.StartsWith('Scripts\') -and $path.EndsWith('.ps1') -and -not $path.EndsWith($name)
		} | Sort-Object
}
