function Install-TestedScripts {
<#
.SYNOPSIS
Installs the project's functions in a dummy module
.DESCRIPTION
Concatenates the .ps1 files in the Scripts subfolder and uses Invoke-Module
on the resulting DummyModule.psm1 file.

The functions are then available for testing with Pester. It is intended for
testing functions in a .ps1 script file.
.LINK <href='Uninstall-TestedScripts.html'>'Uninstall-TestedScripts</a>
#>
	# Returns the name of the dummy module containing the functions
	[CmdletBinding()]
	[OutputType([string])]
	param (
		# The folder containing the PowerShell project
		# The scripts are in the Scripts subfolder
		[string]$ProjectFolder
	)
	$name = [IO.Path]::ChangeExtension([IO.Path]::GetRandomFileName(), '').Replace('.','')
	$folder = "$env:TEMP\$([IO.Path]::ChangeExtension([IO.Path]::GetRandomFileName(), '').Replace('.',''))"
	$path = "$folder\$name.psm1"
	[string]$body = ''
	Get-ChildItem $ProjectFolder\Scripts | ForEach-Object {
		$text = Get-Content $_.FullName | Out-String
		$body += "
$text
"
	}
	if (-not (Test-Path $folder)) {
		mkdir $folder | Out-Null
	}
	$body | Set-Content -Path $path
	if (Get-Module $name -All) {
		Remove-Module $name -Force -ErrorAction Continue
	}
	Import-Module $path -Global
	$name
}
