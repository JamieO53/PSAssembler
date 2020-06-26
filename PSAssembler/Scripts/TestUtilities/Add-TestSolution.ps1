function Add-TestSolution {
	param(
		# The name of the solution
		[string]$Name
	)
	$solutionFolder = "$testDrive\$Name"
	$solutionPath = "$solutionFolder\$Name.sln"
	if (Test-Path $solutionFolder) {
		Remove-Item $solutionFolder/* -Recurse -Force
	} else {
		mkdir $solutionFolder | Out-Null
	}
	"Solution" | Set-Content $solutionPath
	return $solutionFolder
}