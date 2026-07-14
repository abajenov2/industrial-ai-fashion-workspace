# Encoding: keep this file as UTF-8 with BOM for Windows PowerShell 5.1.
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Target,

  [switch]$LibraryOnly,

  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetPath = [System.IO.Path]::GetFullPath($Target)
$Source = Join-Path $RepoRoot "knowledge-base"
$SystemSource = Join-Path $RepoRoot "alliance-system"
$Destination = [System.IO.Path]::Combine(
  $TargetPath,
  "03_Библиотека_роли",
  "01_Открытый_стандарт",
  "Свод_знаний_репозиторий"
)
$SystemDestination = [System.IO.Path]::Combine(
  $TargetPath,
  "03_Библиотека_роли",
  "01_Открытый_стандарт",
  "Система_Альянса"
)

function Copy-DirectoryContents {
  param(
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][string]$DestinationPath
  )

  New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
  Get-ChildItem -LiteralPath $SourcePath -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $DestinationPath -Recurse -Force
  }
}

function Get-TreeStats {
  param([Parameter(Mandatory = $true)][string]$Path)

  return [pscustomobject]@{
    Files = @(Get-ChildItem -LiteralPath $Path -Recurse -File -Force).Count
    Directories = @(Get-ChildItem -LiteralPath $Path -Recurse -Directory -Force).Count
  }
}

function New-UpdateOperation {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][string]$DestinationPath,
    [Parameter(Mandatory = $true)][string]$ValidationRelativePath,
    [Parameter(Mandatory = $true)][string]$TemporaryPrefix,
    [Parameter(Mandatory = $true)][string]$BackupPrefix
  )

  return [pscustomobject]@{
    Name = $Name
    Source = $SourcePath
    Destination = $DestinationPath
    Parent = Split-Path -Parent $DestinationPath
    ValidationRelativePath = $ValidationRelativePath
    TemporaryPrefix = $TemporaryPrefix
    BackupPrefix = $BackupPrefix
    Stage = $null
    Backup = $null
    HadExisting = $false
    Swapped = $false
  }
}

if (-not (Test-Path -LiteralPath (Join-Path $Source "VERSION.json") -PathType Leaf)) {
  throw "Source Knowledge Base version is missing. Run this script from the cloned repository."
}

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
  throw "Resident workspace not found: $TargetPath"
}

$Operations = @(
  (New-UpdateOperation `
    -Name "Knowledge Base" `
    -SourcePath $Source `
    -DestinationPath $Destination `
    -ValidationRelativePath "VERSION.json" `
    -TemporaryPrefix ".alliance-kb-stage-" `
    -BackupPrefix ".alliance-kb-backup-")
)

if (-not $LibraryOnly) {
  if (-not (Test-Path -LiteralPath (Join-Path $SystemSource "navigation/START_HERE.md") -PathType Leaf)) {
    throw "Source Alliance system navigation is missing. Run this script from the cloned repository."
  }
  $Operations += New-UpdateOperation `
    -Name "Alliance system navigation" `
    -SourcePath $SystemSource `
    -DestinationPath $SystemDestination `
    -ValidationRelativePath ([System.IO.Path]::Combine("navigation", "START_HERE.md")) `
    -TemporaryPrefix ".alliance-system-stage-" `
    -BackupPrefix ".alliance-system-backup-"
}

$VersionFile = Join-Path $Source "VERSION.json"
$VersionData = ConvertFrom-Json -InputObject ([System.IO.File]::ReadAllText($VersionFile))
$Mode = "SharedLayer"
if ($LibraryOnly) {
  $Mode = "LibraryOnly"
}

Write-Host "Update mode: $Mode"
Write-Host "Dry run: $($DryRun.IsPresent)"
Write-Host "Target workspace: $TargetPath"
Write-Host "Package version: $($VersionData.package_version)"
Write-Host "Existing destinations are preserved until all staged copies pass validation."
Write-Host "The script will update only:"
foreach ($Operation in $Operations) {
  $Stats = Get-TreeStats -Path $Operation.Source
  Write-Host "  - $($Operation.Name)"
  Write-Host "    Source: $($Operation.Source)"
  Write-Host "    Destination: $($Operation.Destination)"
  Write-Host "    Will create parent folder: $(-not (Test-Path -LiteralPath $Operation.Parent -PathType Container))"
  Write-Host "    Will replace existing destination: $(Test-Path -LiteralPath $Operation.Destination)"
  Write-Host "    Files: $($Stats.Files); directories: $($Stats.Directories)"
}

Write-Host "The script will not modify:"
$ProtectedPaths = @(
  "00_Паспорт_рабочего_места",
  "01_Роль_и_траектория",
  "02_Рабочий_ритм_и_план_работ",
  "04_Проекты_и_рабочие_задачи",
  "05_Встречи_и_цифровой_след",
  "06_Публикации_и_обновления_платформы",
  "07_Права_доступы_авторство",
  "08_Кооперационные_цепочки_и_рынок_роли",
  "99_Архив_исходников"
)
foreach ($ProtectedPath in $ProtectedPaths) {
  Write-Host "  - $ProtectedPath"
}

if ($DryRun) {
  Write-Host "Dry run complete. No files or directories were changed."
  return
}

try {
  foreach ($Operation in $Operations) {
    New-Item -ItemType Directory -Path $Operation.Parent -Force | Out-Null
    $Operation.Stage = Join-Path $Operation.Parent (
      $Operation.TemporaryPrefix + [guid]::NewGuid().ToString("N")
    )
    Copy-DirectoryContents `
      -SourcePath $Operation.Source `
      -DestinationPath $Operation.Stage

    $StagedValidation = Join-Path $Operation.Stage $Operation.ValidationRelativePath
    if (-not (Test-Path -LiteralPath $StagedValidation -PathType Leaf)) {
      throw "Staged $($Operation.Name) is invalid: $StagedValidation is missing."
    }
  }

  foreach ($Operation in $Operations) {
    $Operation.HadExisting = Test-Path -LiteralPath $Operation.Destination
    if ($Operation.HadExisting) {
      $Operation.Backup = Join-Path $Operation.Parent (
        $Operation.BackupPrefix + (Get-Date -Format "yyyyMMdd-HHmmss") + "-" +
        [guid]::NewGuid().ToString("N")
      )
      Move-Item -LiteralPath $Operation.Destination -Destination $Operation.Backup
    }

    Move-Item -LiteralPath $Operation.Stage -Destination $Operation.Destination
    $Operation.Swapped = $true
  }
}
catch {
  $Failure = $_
  for ($Index = $Operations.Count - 1; $Index -ge 0; $Index--) {
    $Operation = $Operations[$Index]
    try {
      if ($Operation.Swapped -and (Test-Path -LiteralPath $Operation.Destination)) {
        Remove-Item -LiteralPath $Operation.Destination -Recurse -Force
      }
      if ($Operation.HadExisting -and $Operation.Backup -and (Test-Path -LiteralPath $Operation.Backup)) {
        if (Test-Path -LiteralPath $Operation.Destination) {
          Remove-Item -LiteralPath $Operation.Destination -Recurse -Force
        }
        Move-Item -LiteralPath $Operation.Backup -Destination $Operation.Destination
      }
      if ($Operation.Stage -and (Test-Path -LiteralPath $Operation.Stage)) {
        Remove-Item -LiteralPath $Operation.Stage -Recurse -Force
      }
    }
    catch {
      Write-Warning "Rollback needs manual inspection for $($Operation.Name): $($_.Exception.Message)"
    }
  }
  throw "Shared library update failed. Existing destinations were restored when possible. $($Failure.Exception.Message)"
}

foreach ($Operation in $Operations) {
  if ($Operation.Backup -and (Test-Path -LiteralPath $Operation.Backup)) {
    try {
      Remove-Item -LiteralPath $Operation.Backup -Recurse -Force
    }
    catch {
      Write-Warning "Update succeeded, but an old backup remains: $($Operation.Backup)"
    }
  }
}

Write-Host "Update completed without changing owner passport, roles, work rhythm or private folders."
Write-Host "Version: $(Join-Path $Destination 'VERSION.json')"
if (-not $LibraryOnly) {
  Write-Host "Start here: $(Join-Path $SystemDestination 'navigation/START_HERE.md')"
}
