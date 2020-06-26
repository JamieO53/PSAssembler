function Get-OutputPath {
    param (
        # Project folder path
        [string]$ProjectFolder,
        # The build configuration
		[string]$Configuration
    )
    $path = "$ProjectFolder\bin"
    if ($Configuration) {
        $path += "\$Configuration"
    }
    return $path
}