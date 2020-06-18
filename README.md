# PSAssembler
PowerShell module and script developer tools
## Overview
PSAssembler assembles modules and scripts from templates and individual powershell scripts. It includes unit testing and disassembly tools. It can be integrated into [PowerShell Tools for Visual Studio](https://marketplace.visualstudio.com/items?itemName=AdamRDriscoll.PowerShellToolsforVisualStudio2017-18561)
The assemblies are validated using the [PowerShell Script Analyzer](https://aka.ms/psscriptanalyzer), allowing them to be published to the [PowerShell Gallery](https://www.powershellgallery.com/)
## Building a module
The module project consists of a folder with the following:
- The module script (.psm1 file) which is usually empty, but could contain imports of required modules and other initialization code
- The module mandate (.psd1 file) with descripion, author, and other fields set
- The Scripts subfolder with scripts (.ps1 files) to include in the assembled module
    - Each script should contain a single function or class
    - It is a good idea to include script level ($Script:) declarations in the scripts that make use of them, keeping things localized
    - the scripts can be organized in subfolders

Invoke Build-PowrShellProject (example build.ps1 script)
```powershell
param (
	[string]$Configuration='Debug',
	[string]$SolutionFolder='',
	[string]$ProjectFolder='',
	[string]$ProjectName=''
)

$ProjectFolder = if ($ProjectFolder) { $ProjectFolder.TrimEnd('\') } else { Get-Location }
$SolutionFolder = if ($SolutionFolder) { $SolutionFolder.TrimEnd('\') } else { Split-Path $ProjectFolder }
$ProjectName = if ($ProjectName) { $ProjectName } else { Split-Path $ProjectFolder -Leaf }

if (-not (Get-Module PSAssembler)) {
	Import-Module PSAssembler -Global -DisableNameChecking
}

Build-PowerShellProject `
	 -Configuration $Configuration `
	 -SolutionFolder $solutionFolder `
	 -ProjectName $ProjectName `
	 -ProjectFolder $ProjectFolder
```
The build output is sent to the bin\\$Configuration subfolder.
If the project folder contains a Visual Studio PowerShell project (.pssproj file) only the scripts specified will be included. Invoke the script from the project pre-build event handler (in the example the script is in the project folder).
```powershell
& .\Build.ps1 -Configuration '$(Configuration)'
```
