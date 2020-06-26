function Add-ProjectScript {
	param (
		# The script name
		[string]$Name,
		# The project file path
		[string]$Path,
		# The script text
		[string]$ScriptText
	)
	$projectFolder = Split-Path $Path
	$scriptFolder = "$projectFolder\Scripts"
	$scriptPath = "$scriptFolder\$Name.ps1"
	$ScriptText | Set-Content -Path $scriptPath
	[xml]$proj = Get-Content $Path
	$compileGroup = $proj.Project.ItemGroup | Where-Object -Property Compile
	[xml]$node = "<Compile Include=`"Scripts\$Name.ps1`" />"
	$compileGroup.AppendChild($compileGroup.AppendChild($proj.ImportNode($node.FirstChild, $true))) | Out-Null
	(Format-XML -XML $proj).Replace(' xmlns=""', '') | Set-Content $Path -Force
}