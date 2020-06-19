# PSAssembler
PowerShell module and script developer tools
## Overview
`PSAssembler` assembles modules and scripts from templates and individual powershell scripts. It includes unit testing and disassembly tools. It can be integrated into [PowerShell Tools for Visual Studio](https://marketplace.visualstudio.com/items?itemName=AdamRDriscoll.PowerShellToolsforVisualStudio2017-18561)
The assemblies are validated using the [PowerShell Script Analyzer](https://aka.ms/psscriptanalyzer), allowing them to be published to the [PowerShell Gallery](https://www.powershellgallery.com/)
## Building a module or script
The module project consists of a folder with the following:
- The module templates
  - The module script (`psm1` file) which is usually empty, but could contain imports of required modules and other initialization code
  - The module mandate (`psd1` file) with descripion, author, and other fields set
- or script template
  - The script (`ps1` file) with a scripts placeholder where the functions are to be placed (see below)
- The Scripts subfolder with scripts (`ps1` files) to include in the assembled module
    - Each script should contain a single function or class
    - It is a good idea to include script level ($`Script`:) declarations in the scripts that make use of them, keeping things localized
    - the scripts can be organized in subfolders

Invoke `Build-PowrShellProject` (example build.ps1 script)
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
	 -ProjectFolder $ProjectFolder `
	 -Check Strict
```
The build output is sent to the bin\\$Configuration subfolder.
If the project folder contains a Visual Studio PowerShell project (`pssproj` file) only the scripts specified will be included. Invoke the script from the project pre-build event handler (in the example the script is in the project folder).
```powershell
& .\Build.ps1 -Configuration '$(Configuration)'
```
[`PSScriptAnalyzer`](https://www.powershellgallery.com/packages/PSScriptAnalyzer) validation is invoked automatically after the script or module is assembled. This error will be thrown if it is not available:
```
[ERROR] The PSScriptAnalyzer module is required to validate the assembled script
[ERROR] + CategoryInfo          : NotSpecified: (:) [], RuntimeException
[ERROR] + FullyQualifiedErrorId : RuntimeException
```
Validation can be suppressed by changing the chec severity to `None`:
```powershell
-Check None
```
in the `Build-PowerShellProject` invocation. Alternatively, install `PSScriptAnalyzer`:
```powershell
Install-Module -Name PSScriptAnalyzer
```
### Script template
A script module looks something like this:
```powershell
param (
    ########## parameters
)

########## Some variable declarations

## <Scripts> ##

########## Other stuff
```
**## &lt;Scripts&gt; ##** is the important part.
## Disassembling a module or script
All modules and scripts contain functions. `Expand-PSFileToScripts` extracts all the functions and classes from a module or script into a project folder's Scripts subfolder, adding templates of the original script file. The module template files need to be added separately.

```powershell
if (-not (Get-Module PSAssembler)) {
	Import-Module PSAssembler -Global -DisableNameChecking
}

Expand-PSFileToScripts `
    -Path $sourcePath `
    -OutputDir . `
    -ModuleName $newModuleOrScriptName
```
