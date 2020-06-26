function Expand-PSFileToScripts {
	param (
		[string]$Path,
		[string]$OutputDir = '.',
		[string]$ModuleName
	)
	if ($PSVersionTable.PSEdition -eq 'Desktop') {
		$PSDefaultParameterValues['Out-File:Encoding'] = 'UTF8'
	} elseif ($PSVersionTable.PSEdition -eq 'Core') {
		$PSDefaultParameterValues['Out-File:Encoding'] = 'UTF8BOM'
	}
	$moduleDir = "$OutputDir\$ModuleName"
	$scriptDir = "$moduleDir\Scripts"
	$myPath = (Get-Item $Path).FullName
	$moduleExtension = [io.path]::GetExtension($myPath)

	if (-not (Test-Path $scriptDir)) {
		mkdir -Path $scriptDir | Out-Null
	}

	$functions = [Executables]::new($myPath)
	$scriptName = $functions.ScriptName
	$functions.ex.Values |
		Where-Object { @('FunctionDefinitionAst', 'TypeDefinitionAst') -contains $_.TypeName } |
		ForEach-Object {
			$outputPath = "$scriptDir\$($_.Name).ps1"
			$_.Ast.Extent.Text | Out-File $outputPath
		}

	$script = $functions.GetExecutable($scriptName).Ast.Extent.Text

	if ($moduleExtension -eq '.ps1'){
		$values=@{StartOffset=0; EndOffset=0}

		$functions.ex.Values |
		Where-Object { @('FunctionDefinitionAst', 'TypeDefinitionAst') -contains $_.TypeName } |
		ForEach-Object { $_.Ast.Extent } |
		Measure-Object -Property 'StartOffset','EndOffset' -min -max |
		ForEach-Object {
			if ( $_.Property -eq 'StartOffset' ) {
				$values[$_.Property] = $_.Minimum
			}
			elseif ( $_.Property -eq 'EndOffset' ) {
				$values[$_.Property] = $_.Maximum
			}
		}

		[int]$fnMinOffset=$values['StartOffset']
		[int]$fnMaxOffset=$values['EndOffset']

		$script.Substring(0,$fnMinOffset) + '## <Scripts> ##' + $script.Substring($fnMaxOffset) |
			Out-File "$moduleDir\$scriptName"
	}
}