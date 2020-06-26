class Executables {
	[string]$ScriptName
    hidden [System.Collections.Generic.Dictionary[string,Executable]]$ex
    Executables([string]$Path) {
		$this.ex = [System.Collections.Generic.Dictionary[string,Executable]]::new()
        $this.ScriptName = [System.IO.Path]::GetFileName($path)
        [System.Collections.Generic.Stack[PSCustomObject]]$scriptStack = [System.Collections.Generic.Stack[PSCustomObject]]::new()
        $scriptStack.Push((New-Object -TypeName PSCustomObject -Property @{ path=$path; container='' }))
        [Executable]$parentContainer = $null
        while ($scriptStack.Count -gt 0) {
            $nextScript = $scriptStack.Pop()
            $filePath = $nextScript.path
            $fileFolder = Split-Path $filePath
            $fileName = Split-Path $filePath -Leaf
            if (-not $this.Contains($fileName)) {
                $parentContainerName = $nextScript.container
                [System.Management.Automation.Language.Token[]]$tokens=$null
                [System.Management.Automation.Language.ParseError[]]$errors=$null
                [System.Management.Automation.Language.ScriptBlockAst]$script=$null
                if ([IO.Path]::GetExtension($filePath) -eq '.psd1' ) {
                    $psd = Import-PowerShellDataFile -Path $filePath
                    $p = "$(Split-Path -Path $filePath)\$($psd.RootModule)"
                } else {
                    $p = $filePath
                }
                if (Test-Path $p) {
                    $script=[System.Management.Automation.Language.Parser]::ParseFile($p, [ref]$tokens, [ref]$errors)
                    if ($errors.Count -gt 0) {
                        $errors |
                            ForEach-Object {
                                Write-Error $_.Message
                            }
                        return
                    }
                    $container = $this.AddExecutable($fileName, $script, $null)
                    if ($parentContainerName) {
                        $parentContainer = $this.GetExecutable($parentContainerName)
                        $parentContainer.AddReference($container)
                    }
                    $script.FindAll({
                                param($ast) $ast.GetType().Name -eq 'CommandAst' -and $ast.CommandElements[0].Value -eq 'Import-Module'
                            }, $true ) | ForEach-Object {
                        [string]$importPath = $_.CommandElements[1].Value
                        if ($importPath.StartsWith('$PSScriptRoot')) {
                            $importPath = $importPath.Replace('$PSScriptRoot', $fileFolder)
                        } elseif ($importPath.StartsWith('.\')) {
                            $importPath = $importPath.Replace('.\', "$fileFolder\")
                        } elseif ($importPath.StartsWith('..\')) {
                            $importPath = "$fileFolder\$importPath"
                        }
                        if ($importPath -and (Test-Path $importPath)) {
                            $scriptStack.Push((New-Object -TypeName PSCustomObject -Property @{ path=$importPath; container=$fileName }))
                        }
                    }
                    # Todo: Only look at the script statements
                    # Todo: Include TypeDefinitionAst as well - Classes (Check TypeAttributes)
                    # Todo: Use Contains / ContainedBy for member functions (FunctionMemberAst)
                    #$fns = $script.FindAll({ param($ast) ($ast.GetType().Name -eq 'FunctionDefinitionAst')}, $false)
                    $fns = $script.EndBlock.Statements |
                        Where-Object { $type = $_.GetType().Name; (@('FunctionDefinitionAst', 'TypeDefinitionAst') -contains $type)}
                    $fns |
                        ForEach-Object {
                            if (-not $this.Contains($_.Name)) {
                                $this.AddExecutable($_.Name, $_, $container) | Out-Null
                            } else { Write-Host "$($_.Name) already exists" }
                        }
                    $parentContainer = $container
                }
            }
        }
        $this.ex.Values |
            ForEach-Object {
                $this.FindExecutableReferences($_)
            }
    }
    [Executable]AddExecutable([string]$name, [System.Management.Automation.Language.Ast]$ast, [Executable]$container) {
        if ($this.Contains($name)) {
            Write-Host "$name already exists"
            Return $null
        } else {
            [Executable]$executable = [Executable]::New($name,$ast,$container)
            $this.ex.Add($name.ToUpper(),$executable)
            if ($executable.TypeName -eq 'TypeDefinitionAst') {
                [System.Management.Automation.Language.TypeDefinitionAst]$cast = $ast -as [System.Management.Automation.Language.TypeDefinitionAst]
                $mbrfns = $cast.Members |
                    Where-Object { $_.GetType().Name -eq 'FunctionMemberAst'}
                $mbrfns |
                    ForEach-Object {
                        [Executable]::new($_.Name,$_,$executable) | Out-Null
                    }
            }
            Return $executable
        }
	}
	[void]FindExecutableReferences ([Executable]$executable) {
        switch -Exact -CaseSensitive ($executable.TypeName) {
            'FunctionDefinitionAst' {
                [System.Management.Automation.Language.FunctionDefinitionAst]$fd = $executable.ast
                $this.FindStatementsReferences($executable, $fd.Body.EndBlock.Statements)
                Break
            }
            'ScriptBlockAst' {
                [System.Management.Automation.Language.ScriptBlockAst]$sb = $executable.ast
                $this.FindStatementsReferences($executable, $sb.EndBlock.Statements)
                Break
            }
            'StatementBlockAst' {
                [System.Management.Automation.Language.StatementBlockAst]$smb = $executable.ast
                $this.FindStatementsReferences($executable, $smb.Statements)
                Break
            }
            # 'TypeDefinitionAst' {
            #     [System.Management.Automation.Language.TypeDefinitionAst]$smb = $executable.ast
            #     $this.FindStatementsReferences($executable, $smb.Statements)
            #     Break
            # }
            default {
            }
        }
    }
    [void]FindStatementsReferences([Executable]$executable, [System.Collections.ObjectModel.ReadOnlyCollection[System.Management.Automation.Language.StatementAst]]$statements){
        $statements |
	        Where-Object {($_ -ne $null) -and (@('FunctionDefinitionAst', 'TypeDefinitionAst') -notcontains $_.GetType().Name)} |
	        ForEach-Object {
		        $this.FindStatementReferences($executable, $_)
	        }
    }
    [void]FindStatementReferences ([Executable]$executable, [System.Management.Automation.Language.StatementAst]$statement) {
	    $commands = $statement.FindAll({ param($ast) ($ast.GetType().Name -eq 'CommandAst')}, $true)
        foreach($command in $commands) {
            $this.FindCommandReferences($executable, $command)
        }
    }
    [void]FindCommandReferences ([Executable]$executable, [System.Management.Automation.Language.CommandBaseAst]$command) {
	    [System.Management.Automation.Language.CommandAst]$c = $command
	    if ($c.CommandElements.count -gt 0) {
		    $action = $c.CommandElements[0]
            $actionType = $action.GetType().Name
		    if (@('ExpandableStringExpressionAst', 'StringConstantExpressionAst') -contains $actionType) {
                $a = $action
			    if ($this.Contains($a.Value)) {
				    $ref = $this.GetExecutable($a.Value)
				    if (!$executable)
				    {
					    $executable.AddReference($ref)
				    }
			    }
		    }
	    }
    }
    [bool]Contains([object]$key)
    {
        [string]$k = $key
        return $this.ex.ContainsKey($k.ToUpper());
    }

    [void]Add([object]$key, [object]$value)
    {
        [string]$k = $key
        $this.ex.Add($k.ToUpper(), $value);
    }

    [void]Clear()
    {
        $this.ex.Clear();
    }

    [System.Collections.IDictionaryEnumerator]GetEnumerator()
    {
        return $this.ex.GetEnumerator();
    }

    [void]Remove([object]$key)
    {
        [string]$k = $key
        $this.ex.Remove($k.ToUpper());
    }

    [object]GetExecutable([object]$key)
    {
        [string]$k = $key
        return $this.ex[$k.ToUpper()];
    }

    [int]Count()
    {
        return $this.ex.Count;
    }
}