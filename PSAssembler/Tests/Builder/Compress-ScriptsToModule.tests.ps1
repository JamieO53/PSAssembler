if (Get-Module CompressTests -All) {
	Remove-Module CompressTests
}
Import-Module $PSScriptRoot\CompressTests.psm1

$testScript = @'
param(
	[string]$Project,
	[string]$Path,
	[string]$OutputPath,
	[string]$Configuration = 'Debug'
)

## <Scripts> ##

Compress-ScriptsToModule -ProjectName $project -ProjectFolder $path -ModuleName "$project.psm1" -Configuration $Configuration
'@
Describe "Compress-ScriptsToModule" {
	BeforeEach {
		$Script:p = New-Params
		New-TestProject $Script:p
	}
	Context "Exists" {
		It "Runable" {
			Test-Path function:\Compress-ScriptsToModule | Should -BeTrue
		}
	}
	Context "Test project setup" {
		It "Should exist in TestDrive" {
			Test-Path $testDrive\Solution | Should -BeTrue
		}
	}
	Context "Build module" {
		BeforeEach {
			Compress-ScriptsToModule `
				-ProjectName $Script:p.projectName `
				-ProjectFolder $Script:p.testProjectFolder `
				-ModuleName $Script:p.moduleName `
				-Configuration Debug
			$Script:modulePath = "$($Script:p.testProjectFolder)\bin\Debug\$($Script:p.moduleName)"
		}
		It "$($Script:p.moduleName) exists" {
			Test-Path $Script:modulePath | Should -BeTrue
		}
		It "Module text" {
			if (Test-Path $Script:modulePath) {
				$actualModuleText = Get-Content $Script:modulePath | Out-String
				$expectedModuleText = Get-Content "$($Script:p.testProjectFolder)\$($Script:p.projectName).psm1"
				$expectedModuleText += Merge-Scripts
				$actualModuleText.Trim() | Should -Be $expectedModuleText.Trim()
			}
		}
	}
	Context "Build script" {
		BeforeEach {
			$scriptName = 'PSModuleBuilder.ps1'
			$scriptPath ="$($Script:p.testProjectFolder)\$scriptName"
			$testScript | Set-Content -Path $scriptPath

			Compress-ScriptsToModule `
				-ProjectName $Script:p.projectName `
				-ProjectFolder $Script:p.testProjectFolder `
				-ModuleName $scriptName `
				-Configuration Debug
			$Script:expectedScriptPath = "$($Script:p.testProjectFolder)\bin\Debug\$scriptName"
		}
		It "$scriptName exists" {
			Test-Path $Script:expectedScriptPath | Should -BeTrue
		}
		It "Script text" {
			if (Test-Path $Script:expectedScriptPath) {
				$actualScriptText = Get-Content $Script:expectedScriptPath | Out-String
				$body = (Merge-Scripts).Trim()
				$expectedScriptText = @"
param(
	[string]`$Project,
	[string]`$Path,
	[string]`$OutputPath,
	[string]`$Configuration = 'Debug'
)

$body

Compress-ScriptsToModule -ProjectName `$project -ProjectFolder `$path -ModuleName `"`$project.psm1`" -Configuration `$Configuration
"@
				$actualScriptText.Trim() | Should -Be $expectedScriptText.Trim()
			}
		}
 	}
}