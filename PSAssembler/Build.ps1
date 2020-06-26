param (
	[string]$Configuration='Debug'
)

$ProjectName = 'PSAssembler'
$ProjectFolder = $PSScriptRoot
$solutionFolder = (Get-Item $projectFolder\..).FullName
$toolsFolder = "$solutionFolder\BuildTools"
. $ProjectFolder\Scripts\Builder\Get-ProjectFunctionIncludes.ps1
. $ProjectFolder\Scripts\Builder\Get-ProjectFunctionText.ps1
. $ProjectFolder\Scripts\Builder\Compress-ScriptsToModule.ps1
. $ProjectFolder\Scripts\Builder\Confirm-Script.ps1
. $ProjectFolder\Scripts\Builder\Get-OutputPath.ps1
$outputFolder = Get-OutputPath -ProjectFolder $projectFolder -Configuration $Configuration

try {
	Compress-ScriptsToModule -ProjectName $ProjectName -ProjectFolder $ProjectFolder -ModuleName "$ProjectName.psm1" -Configuration $Configuration
	Copy-Item $ProjectFolder\$ProjectName.psd1 $outputFolder
	Confirm-Script -Path $outputFolder\$ProjectName.psm1
	if (Test-Path $toolsFolder) {
		Remove-Item $toolsFolder\$projectName.* -Recurse -Force 
	} else {
		mkdir $toolsFolder | Out-Null
	}
	Copy-Item $outputFolder\* $toolsFolder -Recurse -Force
} catch {
	throw $_.Exception
} finally {
	Remove-Item function:\Confirm-Script
	Remove-Item function:\Compress-ScriptsToModule
	Remove-Item function:\Get-OutputPath
	Remove-Item function:\Get-ProjectFunctionText
	Remove-Item function:\Get-ProjectFunctionIncludes
}
