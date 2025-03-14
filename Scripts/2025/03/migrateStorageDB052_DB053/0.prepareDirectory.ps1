#File: cloneDirectory.ps1
#calling example
#      cloneDirectory.ps1 "E:\\Archive" "P:\\Archive"
param (
    [string]$sourceDir,
    [string]$destDir
)
if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory }

Get-ChildItem "$sourceDir" -Recurse -Directory | ForEach-Object {$("mkdir $($_.FullName -replace "$sourceDir", "$destDir")") -replace '\\\\', '\' } 
