$moduleName = "PSAssembler"
if (Get-Module $moduleName) {
	Remove-Module $moduleName
}
$moduleFileName = "$moduleName.psm1"
$modulePath = "$PSScriptRoot\..\..\bin\Debug\$moduleFileName"
$modulePath = (Get-Item $modulePath).FullName
Import-Module $modulePath

$scriptFileName = "$moduleName.ps1"
function CheckExtraction ($testFolder) {
	$expected = @{}
	$scriptsFolder = "$PSScriptRoot\..\..\Scripts"
	Get-ChildItem $scriptsFolder\*.ps1 -Recurse -File | ForEach-Object {
		$expected[$_.Name] = $_.FullName
	}
	$actual = @{}
	Get-ChildItem $testFolder\$moduleName\Scripts -Recurse -File | ForEach-Object {
		$actual[$_.Name] = $_.FullName
	}
	It "Number of executables" {
		$actual.Count | Should -Be $expected.Count
	}
	$expected.Keys | Sort-Object | ForEach-Object {
		$name = $_
		It "$name extracted" {
			$actual.ContainsKey($name) | Should -BeTrue
		}
		if ($actual.ContainsKey($name)) {
			$expectedText = Get-Content $expected[$name] | Out-String
			$actualText = Get-Content $actual[$name] | Out-String
			It "$name text" {
				$actualText.Trim() | Should -Be $expectedText.Trim()
			}
		}
	}
}

Describe "Expand-PSFileToScripts" {
	Context "Exists" {
		It "Runnable" {
			Test-Path Function:\Expand-PSFileToScripts | Should -BeTrue
		}
	}
	Context "Expand module" {
		$testFolder = "$testDrive\Test"
		mkdir $testFolder
		Copy-Item $modulePath $testFolder
		Expand-PSFileToScripts -Path "$testFolder\$moduleFileName" -OutputDir $testFolder -ModuleName $moduleName
		It "Script folder" {
			Test-Path $testFolder\$moduleName\Scripts | Should -BeTrue
		}
		It "Edited input file" {
			Test-Path $testFolder\$moduleName\$moduleFileName | Should -BeFalse
		}
		CheckExtraction $testFolder
	}
	Context "Expand script" {
		$testFolder = "$testDrive\Test"
		mkdir $testFolder
		$functions = (Get-Content $modulePath | Out-String).Trim()
		$script = @"
param (
	[string]`$Path,
	[string]`$OutputDir,
	[string]`$ModuleName
)
$functions

Expand-PSFileToScripts -Path `$Path -OutputDir `$OutputDir -ModuleName `$ModuleName
"@
		$expectedScript = @"
param (
	[string]`$Path,
	[string]`$OutputDir,
	[string]`$ModuleName
)
## <Scripts> ##

Expand-PSFileToScripts -Path `$Path -OutputDir `$OutputDir -ModuleName `$ModuleName


"@
		$script | Out-File $testFolder\$scriptFileName
		Expand-PSFileToScripts -Path "$testFolder\$scriptFileName" -OutputDir $testFolder -ModuleName $moduleName
		It "Script folder" {
			Test-Path $testFolder\$moduleName\Scripts | Should -BeTrue
		}
		It "Edited input file" {
			Test-Path $testFolder\$moduleName\$scriptFileName | Should -BeTrue
		}
		if (Test-Path $testFolder\$moduleName\$scriptFileName) {
			$actualScript = Get-Content $testFolder\$moduleName\$scriptFileName | Out-String
			It "Edited script text" {
				$actualScript | Should -Be $expectedScript
			}
		}
		CheckExtraction $testFolder
	}
}