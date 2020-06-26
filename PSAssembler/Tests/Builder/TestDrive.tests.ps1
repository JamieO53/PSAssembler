
# Test for a bug in Pester v 5.0. Use Pester v 4.10.1 instead
Describe "Test drive available" {
    Context "Directly" {
        It "Should exist" {
            Test-Path $testDrive.FullName | Should -BeTrue
        }
	}
    Context "Indirectly" {
		$td = $testDrive.FullName
		It "Should exist" {
            Test-Path $td | Should -BeTrue
        }
	}
}