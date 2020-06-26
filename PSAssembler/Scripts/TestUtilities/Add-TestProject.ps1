function Add-TestProject {
    param (
        # The project name
        [string]$Name,
        # The path of the solution folder containing the project
        [string]$SolutionFolder
    )
    $projectFolder = "$SolutionFolder\$Name"
    $projectScriptFolder = "$projectFolder\Scripts"
    $projectPath = "$projectFolder\$Name.ppsproj"
    $scriptModulePath = "$projectFolder\$Name.psm1"
    $scriptManifestPath = "$projectFolder\$Name.psd1"
    if (Test-Path $projectFolder) {
        Remove-Item $projectFolder\* -Recurse -Force
    }
    mkdir $projectScriptFolder | Out-Null
    @"
<Project ToolsVersion=`"4.0`" DefaultTargets=`"Build`" xmlns=`"http://schemas.microsoft.com/developer/msbuild/2003`">
    <ItemGroup>
        <Folder Include=`"Scripts\`" />
    </ItemGroup>
    <ItemGroup>
        <Compile Include=`"$Name.psd1`" />
        <Compile Include=`"$Name.psm1`" />
    </ItemGroup>
</Project>
"@ | Set-Content $projectPath
    "" | Set-Content $scriptModulePath
    New-ModuleManifest -Path $scriptManifestPath -RootModule "$Name.psm1" `
        -ModuleVersion '0.1.0' -Author JamieO53 -CompanyName JamieO53 -Description 'Description' `
        -FunctionsToExport '*'
    return $projectFolder
}