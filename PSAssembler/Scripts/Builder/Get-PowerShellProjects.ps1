function Get-PowerShellProjects {
    <#.Synopsis
        Get the solution's C# projects
    .DESCRIPTION
        Examines the Solution file and extracts a list of the project names and their locations relative to the solution
    .EXAMPLE
        Get-PowerShellProjects -SolutionPath .\EcsShared | ForEach-Object {
            $projName = $_.Project
            [xml]$proj = Get-Content $_.ProjectPath
        }
    #>
    [CmdletBinding()]
    param
    (
        # The solution path
        [string]$SolutionPath
    )
    $projId = '{F5034706-568F-408A-B7B3-4D38C6DB8A32}' # PowerShell project
    [string]$sln=if ($SolutionPath -and (Test-Path $SolutionPath)) {Get-Content $SolutionPath | Out-String} else {''}

    $nameGrouping = '(?<name>[^"]+)'
    $pathGrouping = '(?<path>[^"]+)'
    $guidGrouping = '(?<guid>[^\}]+)'
    $regex = "\r\nProject\(`"$projId`"\)\s*=\s*`"$nameGrouping`"\s*,\s*`"$pathGrouping`",\s*`"\{$guidGrouping\}`".*"
    $matched = ([regex]$regex).Matches($sln)

    $matched | ForEach-Object {
		$projName = $_.Groups['name'].Value
        $projPath = $_.Groups['path'].Value
        $projGuid = $_.Groups['guid'].Value
        New-Object -TypeName PSObject -Property @{
            Project = $projName;
            ProjectPath = $projPath;
            ProjectGuid = $projGuid
        }
    }
}