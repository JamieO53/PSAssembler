$moduleName = "PSAssembler"
if (Get-Module $moduleName) {
	Remove-Module $moduleName
}
$moduleFileName = "$moduleName.psd1"
$modulePath = "$PSScriptRoot\..\..\bin\Debug\$moduleFileName"
$modulePath = (Get-Item $modulePath).FullName
Import-Module $modulePath

Describe "Install-TestedScripts" {
	Context "Exists" {
		It "Runnable" {
			Test-Path Function:\Install-TestedScripts | Should -BeTrue
		}
	}
}