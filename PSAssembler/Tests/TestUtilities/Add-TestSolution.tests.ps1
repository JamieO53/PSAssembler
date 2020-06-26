if (Get-Module PSAssembler) {
    Remove-Module PSAssembler
}
Import-Module $PSScriptRoot\..\..\bin\Debug\PSAssembler.psm1

Describe "Add-TestSolution" {
	Context "Exists" {
		It "Runable" {
			Test-Path function:\Add-TestSolution | Should -BeTrue
		}
	}
	Context "Solution content" {
		$slnName = 'TestSln'
		$expectedSlnFolder = "TestDrive:\$slnName"
		$slnFolder = Add-TestSolution -Name $slnName
		It "Solution folder exists"  {
			Test-Path $expectedSlnFolder | Should -BeTrue
		}
		It "Solution is where expected" {
			(Get-Item $slnFolder).FullName | Should -Be (Get-Item $expectedSlnFolder).FullName
		}
		It "Solution file exists" {
			Test-Path $slnFolder\$slnName.sln | Should -BeTrue
		}
	}
}