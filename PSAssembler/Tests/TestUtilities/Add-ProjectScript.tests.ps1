if (Get-Module PSAssembler) {
    Remove-Module PSAssembler
}
Import-Module $PSScriptRoot\..\..\bin\Debug\PSAssembler.psm1

Describe "Add-ProjectScript" {
	Context "Exists" {
		It "Runable" {
			Test-Path function:\Add-ProjectScript | Should -BeTrue
		}
	}
	Context "Add script to project" {
		$slnName = 'Sln'
		$projName = 'Proj'
		$scriptName = 'Add-Dummy'
		$scriptText = @"
function $scriptName {
	# Do nothing
}
"@
		$slnFolder = Add-TestSolution -Name $slnName
		$projFolder = Add-TestProject -Name $projName -SolutionFolder $slnFolder
		$projPath = "$projFolder\$projName.ppsproj"
		Add-ProjectScript -Name $scriptName -Path $projPath -ScriptText $scriptText
		It "Script file exists" {
			Test-Path $projFolder\Scripts\$scriptName.ps1 | Should -BeTrue
		}
		It "Script file referenced by project" {
			Get-Content -Path $projPath | Where-Object {
				$_.Trim() -eq "<Compile Include=`"Scripts\$scriptName.ps1`" />"
			} | Should -Not -BeNullOrEmpty
		}
	}
}