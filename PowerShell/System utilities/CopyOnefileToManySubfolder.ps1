$sourceFile = ".\SonarQube\ReadMe.md"
$destinationFolder = ".\SonarQube"

Get-ChildItem -Path $destinationFolder -Directory | ForEach-Object {
    Copy-Item -Path $sourceFile -Destination $_.FullName
}
