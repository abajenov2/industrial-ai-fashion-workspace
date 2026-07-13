[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("brand", "marka", "expert", "factory", "architect")]
  [string]$Type,

  [Parameter(Mandatory = $true)]
  [string]$Target
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RoleTemplate = if ($Type -eq "marka") { "brand" } else { $Type }
$TargetPath = [System.IO.Path]::GetFullPath($Target)

function Copy-DirectoryContents {
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Destination
  )

  New-Item -ItemType Directory -Path $Destination -Force | Out-Null
  Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $Destination -Recurse -Force
  }
}

$RequiredDirectories = @(
  (Join-Path $RepoRoot "templates/common"),
  (Join-Path $RepoRoot "templates/$RoleTemplate"),
  (Join-Path $RepoRoot "knowledge-base"),
  (Join-Path $RepoRoot "skills/alliance-resident-workspace")
)

foreach ($Required in $RequiredDirectories) {
  if (-not (Test-Path -LiteralPath $Required -PathType Container)) {
    throw "Installation package is incomplete: $Required"
  }
}

if (Test-Path -LiteralPath $TargetPath) {
  $ExistingItem = Get-ChildItem -LiteralPath $TargetPath -Force | Select-Object -First 1
  if ($null -ne $ExistingItem) {
    throw "Target directory is not empty: $TargetPath. Choose an empty directory."
  }
}

New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
Copy-DirectoryContents (Join-Path $RepoRoot "templates/common") $TargetPath
Copy-DirectoryContents (Join-Path $RepoRoot "templates/$RoleTemplate") $TargetPath

$LibraryTarget = [System.IO.Path]::Combine(
  $TargetPath,
  "03_Библиотека_роли",
  "01_Открытый_стандарт",
  "Свод_знаний_репозиторий"
)
$SkillTarget = [System.IO.Path]::Combine(
  $TargetPath,
  "09_Скиллы_для_Codex",
  "alliance-resident-workspace"
)
New-Item -ItemType Directory -Path (Split-Path -Parent $LibraryTarget) -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $SkillTarget) -Force | Out-Null
Copy-DirectoryContents (Join-Path $RepoRoot "knowledge-base") $LibraryTarget
Copy-DirectoryContents (Join-Path $RepoRoot "skills/alliance-resident-workspace") $SkillTarget

$InstalledChecks = @(
  @{ Label = "Knowledge Base version"; Path = (Join-Path $LibraryTarget "VERSION.json") },
  @{ Label = "Codex skill"; Path = (Join-Path $SkillTarget "SKILL.md") }
)

foreach ($Check in $InstalledChecks) {
  if (-not (Test-Path -LiteralPath $Check.Path -PathType Leaf)) {
    $LeafName = Split-Path -Leaf $Check.Path
    $Found = @(
      Get-ChildItem -LiteralPath $TargetPath -Recurse -File -Filter $LeafName -ErrorAction SilentlyContinue |
        ForEach-Object { $_.FullName }
    )
    throw "$($Check.Label) is missing at $($Check.Path). Found: $($Found -join '; ')"
  }
}

Write-Host "Workspace installed: $TargetPath"
Write-Host "Type: $RoleTemplate"
Write-Host "Next: open this folder in Codex and ask it to help fill in the workspace passport."
