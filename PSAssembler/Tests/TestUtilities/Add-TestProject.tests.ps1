if (Get-Module PSAssembler) {
    Remove-Module PSAssembler
}
Import-Module $PSScriptRoot\..\..\bin\Debug\PSAssembler.psm1

Describe "Add-TestProject" {
	Context "Exists" {
		It "Runable" {
			Test-Path function:\Add-TestProject | Should -BeTrue
		}
	}
	Context "Project content" {
		$projName = 'Proj'
		$slnFolder = Add-TestSolution -Name Sln
		$projFolder = Add-TestProject -Name $projName -SolutionFolder $slnFolder
		$projPath = "$projFolder\$projName.ppsproj"
		$expectdProjFolder = "TestDrive:\Sln\$projName"
		It "Test project folder exists" {
			Test-Path $expectdProjFolder | Should -BeTrue
		}
		It "Project is where expected" {
			(Get-Item $projFolder).FullName | Should -Be (Get-Item $expectdProjFolder).FullName
		}
		It "Project file exists" {
			Test-Path $projPath | Should -BeTrue
		}
		It "Project contains script module file" {
			Test-Path $projFolder\$projName.psm1 | Should -BeTrue
		}
		It "Project contains script manifest file" {
			Test-Path $projFolder\$projName.psd1 | Should -BeTrue
		}
		It "Project contains Scripts subfolder" {
			Test-Path $projFolder\Scripts | Should -BeTrue
		}
		It "Project file contains Scripts subfolder reference" {
			Get-Content $projPath | Where-Object {
				$_.Trim() -eq '<Folder Include="Scripts\" />'
			} | Should -Not -BeNullOrEmpty
		}
		It "Project file contains script module reference" {
			Get-Content $projPath | Where-Object {
				$_.Trim() -eq "<Compile Include=`"$projName.psm1`" />"
			} | Should -Not -BeNullOrEmpty
		}
		It "Project file contains module manifest reference" {
			Get-Content $projPath | Where-Object {
				$_.Trim() -eq "<Compile Include=`"$projName.psd1`" />"
			} | Should -Not -BeNullOrEmpty
		}
	}
}