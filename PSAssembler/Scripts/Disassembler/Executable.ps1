class Executable {
	[string]$Name
	[System.Management.Automation.Language.Ast]$Ast
	[string]$TypeName
	[System.Collections.Generic.List[Executable]]$References
	[System.Collections.Generic.List[Executable]]$ReferencedBy
	[Executable]$ContainedBy
	[System.Collections.Generic.Dictionary[string,Executable]]$Contains
 	Executable($name,$ast,$container) {
		$this.Name = $name
		$this.Ast = $ast
		$this.TypeName = $ast.GetType().Name
		$this.References = [System.Collections.Generic.List[Executable]]::new()
		$this.ReferencedBy = [System.Collections.Generic.List[Executable]]::new()
		$this.ContainedBy = $container
		if (@('ScriptBlockAst', 'TypeDefinitionAst') -contains $this.TypeName) {
			$this.Contains = [System.Collections.Generic.Dictionary[string,Executable]]::new()
		}
		if ($container) {
			$container.Contains[$name.ToUpper()] = $this
		}
	}
	[void]AddReference([Executable]$reference) {
		if(-not ($this.References.Contains($reference))) {
			$this.References.Add($reference)
		}
		if(-not ($Reference.referencedBy.Contains($this))) {
			$Reference.referencedBy.Add($this)
		}
	}
	[string]Text() {
		return $this.Ast.Extent.Text
	}
	[bool]IsImported() {
		if ($this.TypeName -eq 'ScriptBlockAst') {
			return $this.ReferencedBy.Count -gt 0
		} else {
			return $this.ContainedBy.IsImported()
		}
	}
	[string]QualifiedName() {
		if ($this.IsImported() -and $this.TypeName -ne 'ScriptBlockAst') {
			return "$($this.ContainedBy.QualifiedName()).$($this.Name)"
		} else {
			return [IO.Path]::GetFileNameWithoutExtension($this.Name)
		}
	}
}