if (Test-Path function:\Compress-ScriptsToModule) {
	Remove-Item function:\Compress-ScriptsToModule
}
if (Test-Path function:\Get-ProjectFunctionText) {
	Remove-Item function:\Get-ProjectFunctionText
}
if (Get-Module PSAssembler) {
	Remove-Module PSAssembler
}


function Merge-Scripts {
    $mergedText = ''
    Get-ChildItem $PSScriptRoot\..\..\Scripts\*\*.ps1 | ForEach-Object {
        $text = (Get-Content $_.FullName | Out-String).Trim()
        $mergedText += "

$text"
    }
    $mergedText
}
function New-Params {
	$p = @{}
    $p.projectFolder = (Get-Item "$PSScriptRoot\..\..").FullName
    $p.solutionFolder = Split-Path $p.projectFolder
    $p.projectName = Split-Path $p.projectFolder -Leaf
	$p.moduleName = "$($p.projectName).psm1"
	$p.testDrive = $TestDrive
    return $p
}

function New-TestProject {
	param (
		[hashtable]$p
	)
	$p.testSolutionFolder = "$($p.testDrive)\Solution"
	$p.testProjectFolder = "$($p.testSolutionFolder)\$($p.projectName)"
	if (Test-Path $p.testSolutionFolder) {
		Remove-Item $p.testSolutionFolder -Recurse
	}
	mkdir "$($p.testProjectFolder)\Scripts" | Out-Null
	Copy-Item "$($p.projectFolder)\$($p.projectName).pssproj", "$($p.projectFolder)\$($p.projectName).ps*1" $p.testProjectFolder -Force
	Copy-Item "$($p.projectFolder)\Scripts\*" "$($p.testProjectFolder)\Scripts" -Recurse -Force
}

function Remove-Functions {
	if (Test-Path function:\Compress-ScriptsToModule) {
		Remove-Item function:\Compress-ScriptsToModule
	}
	if (Test-Path function:\Get-ProjectFunctionText) {
		Remove-Item function:\Get-ProjectFunctionText
	}
	if (Test-Path function:\Get-ProjectFunctionIncludes) {
		Remove-Item function:\Get-ProjectFunctionIncludes
	}
	if (Get-Module PSAssembler) {
		Remove-Module PSAssembler
	}
}

Remove-Functions
. $PSScriptRoot\..\..\Scripts\Builder\Compress-ScriptsToModule
. $PSScriptRoot\..\..\Scripts\Builder\Get-ProjectFunctionIncludes
. $PSScriptRoot\..\..\Scripts\Builder\Get-ProjectFunctionText