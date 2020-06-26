function Merge-Scripts {
    param (
        # Path of the scripts folder
        [string]$Path
    )
    $mergedText = ''
    Get-ChildItem $Path\*.ps1 -Recurse | ForEach-Object {
        $text = (Get-Content $_.FullName | Out-String).Trim()
        $mergedText += "

$text"
    }
    $mergedText
}
