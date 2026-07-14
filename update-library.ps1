# Encoding: keep this file as UTF-8 with BOM for Windows PowerShell 5.1.
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Target
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetPath = [System.IO.Path]::GetFullPath($Target)
$Source = Join-Path $RepoRoot "knowledge-base"
$SystemSource = Join-Path $RepoRoot "alliance-system"
$Destination = Join-Path $TargetPath "03_Библиотека_роли/01_Открытый_стандарт/Свод_знаний_репозиторий"
$SystemDestination = Join-Path $TargetPath "03_Библиотека_роли/01_Открытый_стандарт/Система_Альянса"

if (-not (Test-Path -LiteralPath (Join-Path $Source "VERSION.json") -PathType Leaf)) {
  throw "Source Knowledge Base version is missing. Run this script from the cloned repository."
}

if (-not (Test-Path -LiteralPath (Join-Path $SystemSource "navigation/START_HERE.md") -PathType Leaf)) {
  throw "Source Alliance system navigation is missing. Run this script from the cloned repository."
}

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
  throw "Resident workspace not found: $TargetPath"
}

$Temporary = "$Destination.update"
if (Test-Path -LiteralPath $Temporary) {
  Remove-Item -LiteralPath $Temporary -Recurse -Force
}
Copy-Item -LiteralPath $Source -Destination $Temporary -Recurse -Force

if (Test-Path -LiteralPath $Destination) {
  Remove-Item -LiteralPath $Destination -Recurse -Force
}
Move-Item -LiteralPath $Temporary -Destination $Destination

$SystemTemporary = "$SystemDestination.update"
if (Test-Path -LiteralPath $SystemTemporary) {
  Remove-Item -LiteralPath $SystemTemporary -Recurse -Force
}
Copy-Item -LiteralPath $SystemSource -Destination $SystemTemporary -Recurse -Force

if (Test-Path -LiteralPath $SystemDestination) {
  Remove-Item -LiteralPath $SystemDestination -Recurse -Force
}
Move-Item -LiteralPath $SystemTemporary -Destination $SystemDestination

Write-Host "Knowledge Base and Alliance system navigation updated without changing private resident folders."
Write-Host "Version: $(Join-Path $Destination 'VERSION.json')"
Write-Host "Start here: $(Join-Path $SystemDestination 'navigation/START_HERE.md')"
