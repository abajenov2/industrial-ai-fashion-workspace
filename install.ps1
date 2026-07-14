# Encoding: keep this file as UTF-8 with BOM for Windows PowerShell 5.1.
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Target
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
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
  (Join-Path $RepoRoot "templates/workspace"),
  (Join-Path $RepoRoot "knowledge-base"),
  (Join-Path $RepoRoot "alliance-system"),
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
Copy-DirectoryContents (Join-Path $RepoRoot "templates/workspace") $TargetPath

$StandardDirectories = @(
  "04_Проекты_и_рабочие_задачи",
  "05_Встречи_и_цифровой_след",
  "06_Публикации_и_обновления_платформы",
  "08_Кооперационные_цепочки_и_рынок_роли",
  "99_Архив_исходников"
)
foreach ($Directory in $StandardDirectories) {
  New-Item -ItemType Directory -Path (Join-Path $TargetPath $Directory) -Force | Out-Null
}

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
$SystemTarget = [System.IO.Path]::Combine(
  $TargetPath,
  "03_Библиотека_роли",
  "01_Открытый_стандарт",
  "Система_Альянса"
)
New-Item -ItemType Directory -Path (Split-Path -Parent $LibraryTarget) -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $SystemTarget) -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $SkillTarget) -Force | Out-Null
Copy-DirectoryContents (Join-Path $RepoRoot "knowledge-base") $LibraryTarget
Copy-DirectoryContents (Join-Path $RepoRoot "alliance-system") $SystemTarget
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
Write-Host "Model: unified resident workspace"
Write-Host "Next: open this folder in Codex and fill in the owner context, roles and nearest task."
