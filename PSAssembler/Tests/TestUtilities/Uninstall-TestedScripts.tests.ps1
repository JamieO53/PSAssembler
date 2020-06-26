$moduleName = "PSAssembler"
if (Get-Module $moduleName) {
	Remove-Module $moduleName
}
$moduleFileName = "$moduleName.psd1"
$modulePath = "$PSScriptRoot\..\..\bin\Debug\$moduleFileName"
$modulePath = (Get-Item $modulePath).FullName
Import-Module $modulePath

Describe "Uninstall-TestedScripts" {
	Context "Exists" {
		It "Runnable" {
			Test-Path Function:\Expand-PSFileToScripts | Should -BeTrue
		}
	}
}