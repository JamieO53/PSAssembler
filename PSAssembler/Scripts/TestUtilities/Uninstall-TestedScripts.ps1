function Uninstall-TestedScripts {
<#
.SYNOPSIS
Removes the testing dummy module if any
.DESCRIPTION
Concatenates the .ps1 files in the Scripts subfolder and uses Invoke-Module
on the resulting DummyModule.psm1 file.

The functions are then available for testing with Pester. It is intended for
testing functions in a .ps1 script file.
.LINK <href='Install-TestedScripts.html>Install-TestedScripts</a>
#>
    param (
        [string]$DummyModuleName
    )
    if (Get-Module $DummyModuleName -All){
        $path = (Get-Module $DummyModuleName -All).Path
        Remove-Module $DummyModuleName -Force -ErrorAction Continue
        if ($path.StartsWith($env:TEMP)) {
            Remove-Item $path
            Remove-Item (Split-Path $path)
        }
    }
}