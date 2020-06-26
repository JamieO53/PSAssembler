function Get-ProjectFunctionText {
	param (
		[xml]$proj,
		[string]$ModuleName
	)
	[string]$body = ''
	Get-ProjectFunctionIncludes -proj $proj -ModuleName $ModuleName | ForEach-Object {
			[string]$fn = (Get-Content "$ProjectFolder\$($_)" | Out-String).Trim()
			$body += "$fn

"
		}
	$body.Trim()
}
