$moduleName = "BuilderTests"
if (Get-Module $moduleName) {
	Remove-Module $moduleName
}
Import-Module $PSScriptRoot\$moduleName.psm1

Describe "Build-PowerShellProject" {
	Context "Exists" {
		It "Runable" {
			Test-Path function:\Build-PowerShellProject | Should -BeTrue
		}
	}
}
# Describe "Selected scripts in project" {

# }