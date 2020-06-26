function Confirm-Script {
    param (
        # The path of the assembled script
        [string]$Path
    )
    if (-not (Get-Module PSScriptAnalyzer -All)) {
        if (Get-Module PSScriptAnalyzer -ListAvailable) {
            Import-Module PSScriptAnalyzer
        } else {
            throw "The PSScriptAnalyzer module is required to validate the assembled script"
        }
    }
    Invoke-ScriptAnalyzer -Path $Path
    if ([io.path]::GetExtension($Path) -eq '.psm1') {
        $moduleName = [io.Path]::ChangeExtension((Split-Path -Path $Path -Leaf), '')
        $manifestPath = [io.path]::ChangeExtension($Path, '.psd1')
        if (Test-Path $manifestPath) {
            Test-ModuleManifest -Path $manifestPath
        } else {
            $name = Split-Path $manifestPath -Leaf
            throw "The manifest for $name cannot be found"
        }
        try {
            "Importing $moduleName"
            if (Get-Module $moduleName -All) {
                Remove-Module $moduleName
            }
            Import-Module $Path
            $m = Import-PowerShellDataFile $manifestPath
            $m.FunctionsToExport | ForEach-Object {
                if (!(Test-Path function:\$_)) {
                    throw "Exported function $_ is not in $moduleName"
                }
            }
        } finally {
            if (Get-Module $moduleName -All) {
                Remove-Module $moduleName
            }
        }
    }
    else {
        Test-ScriptFileInfo -Path $Path
    }
}