if (Get-Module CompressTests -All) {
	Remove-Module CompressTests
}
$moduleName = "PSAssembler"
if (Get-Module $moduleName) {
	Remove-Module $moduleName
}
$moduleFileName = "$moduleName.psm1"
$modulePath = "$PSScriptRoot\..\..\..\BuildTools\$moduleFileName"
$modulePath = (Get-Item $modulePath).FullName
Import-Module $modulePath

