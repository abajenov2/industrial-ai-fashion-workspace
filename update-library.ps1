[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Target
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetPath = [System.IO.Path]::GetFullPath($Target)
$Source = Join-Path $RepoRoot "knowledge-base"
$Destination = Join-Path $TargetPath "03_Библиотека_роли/01_Открытый_стандарт/Свод_знаний_репозиторий"

if (-not (Test-Path -LiteralPath (Join-Path $Source "VERSION.json") -PathType Leaf)) {
  throw "Source Knowledge Base version is missing. Run this script from the cloned repository."
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

Write-Host "Knowledge Base updated without changing private resident folders."
Write-Host "Version: $(Join-Path $Destination 'VERSION.json')"
