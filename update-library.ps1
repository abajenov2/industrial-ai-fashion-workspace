# Encoding: keep this file as UTF-8 with BOM for Windows PowerShell 5.1.
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Target,

  [switch]$LibraryOnly,

  [switch]$DryRun,

  [switch]$CheckWriteAccess
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

function Wait-LiteralPath {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][ValidateSet("Container", "Leaf")][string]$PathType,
    [int]$Attempts = 10,
    [int]$DelayMilliseconds = 100
  )

  for ($Attempt = 1; $Attempt -le $Attempts; $Attempt++) {
    if (Test-Path -LiteralPath $Path -PathType $PathType) {
      return $true
    }
    Start-Sleep -Milliseconds $DelayMilliseconds
  }

  return $false
}

function New-LiteralDirectory {
  param([Parameter(Mandatory = $true)][string]$Path)

  [System.IO.Directory]::CreateDirectory($Path) | Out-Null
  if (-not (Wait-LiteralPath -Path $Path -PathType "Container")) {
    throw "Failed to create directory: $Path"
  }
}

function Invoke-WritePreflight {
  param([Parameter(Mandatory = $true)][string]$ParentPath)

  if (
    (Test-Path -LiteralPath $ParentPath) -and
    -not (Test-Path -LiteralPath $ParentPath -PathType Container)
  ) {
    throw "Write preflight target exists but is not a directory: $ParentPath"
  }

  $ProbeParent = $ParentPath
  while (-not (Test-Path -LiteralPath $ProbeParent -PathType Container)) {
    $NextParent = Split-Path -Parent $ProbeParent
    if (-not $NextParent -or $NextParent -eq $ProbeParent) {
      throw "Write preflight could not find an existing parent for: $ParentPath"
    }
    $ProbeParent = $NextParent
  }

  $ProbeDirectory = [System.IO.Path]::Combine(
    $ProbeParent,
    ("_aw-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
  )
  $ProbeFile = [System.IO.Path]::Combine($ProbeDirectory, "probe.txt")
  $ProbeText = "alliance-write-preflight"
  $PreflightFailure = $null

  try {
    New-LiteralDirectory -Path $ProbeDirectory
    $Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($ProbeFile, $ProbeText, $Utf8NoBom)
    if (-not (Wait-LiteralPath -Path $ProbeFile -PathType "Leaf")) {
      throw "Failed to create preflight file: $ProbeFile"
    }
    if ([System.IO.File]::ReadAllText($ProbeFile) -ne $ProbeText) {
      throw "Preflight file could not be read back correctly: $ProbeFile"
    }
  }
  catch {
    $PreflightFailure = $_.Exception
  }
  finally {
    try {
      if (Test-Path -LiteralPath $ProbeDirectory) {
        Remove-Item -LiteralPath $ProbeDirectory -Recurse -Force
      }
    }
    catch {
      if (-not $PreflightFailure) {
        $PreflightFailure = $_.Exception
      }
    }
  }

  if (Test-Path -LiteralPath $ProbeDirectory) {
    throw "Write preflight left a temporary directory: $ProbeDirectory"
  }
  if ($PreflightFailure) {
    throw "Write preflight failed for $ParentPath via $ProbeParent. $($PreflightFailure.Message)"
  }

  Write-Host "Write preflight passed for: $ParentPath"
  Write-Host "Write probe location: $ProbeParent"
}

function Copy-DirectoryContents {
  param(
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][string]$DestinationPath
  )

  New-LiteralDirectory -Path $DestinationPath
  $TrimCharacters = [char[]]@(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar
  )
  $SourceRoot = [System.IO.Path]::GetFullPath($SourcePath).TrimEnd($TrimCharacters)
  $RelativeStart = $SourceRoot.Length + 1

  Get-ChildItem -LiteralPath $SourceRoot -Recurse -Directory -Force |
    ForEach-Object {
      $RelativePath = $_.FullName.Substring($RelativeStart)
      $TargetDirectory = [System.IO.Path]::Combine($DestinationPath, $RelativePath)
      New-LiteralDirectory -Path $TargetDirectory
    }

  Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -Force |
    ForEach-Object {
      $RelativePath = $_.FullName.Substring($RelativeStart)
      $TargetFile = [System.IO.Path]::Combine($DestinationPath, $RelativePath)
      New-LiteralDirectory -Path (Split-Path -Parent $TargetFile)
      [System.IO.File]::Copy($_.FullName, $TargetFile, $true)
      if (-not (Wait-LiteralPath -Path $TargetFile -PathType "Leaf")) {
        throw "Copied file did not appear in staging: $TargetFile"
      }
    }

  if (-not (Test-Path -LiteralPath $DestinationPath -PathType Container)) {
    throw "Staging directory disappeared after copy: $DestinationPath"
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
    -TemporaryPrefix "_kb-s-" `
    -BackupPrefix "_kb-b-")
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
    -TemporaryPrefix "_sys-s-" `
    -BackupPrefix "_sys-b-"
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
  if ($CheckWriteAccess) {
    $CheckedParents = @{}
    foreach ($Operation in $Operations) {
      if (-not $CheckedParents.ContainsKey($Operation.Parent)) {
        Invoke-WritePreflight -ParentPath $Operation.Parent
        $CheckedParents[$Operation.Parent] = $true
      }
    }
    Write-Host "Dry run and write preflight complete. Temporary probes were removed."
  }
  else {
    Write-Host "Write preflight was not run. Add -CheckWriteAccess to test create/write/read/delete access."
    Write-Host "Dry run complete. No files or directories were changed."
  }
  return
}

$CheckedParents = @{}
foreach ($Operation in $Operations) {
  if (-not $CheckedParents.ContainsKey($Operation.Parent)) {
    Invoke-WritePreflight -ParentPath $Operation.Parent
    $CheckedParents[$Operation.Parent] = $true
  }
}

try {
  foreach ($Operation in $Operations) {
    New-LiteralDirectory -Path $Operation.Parent
    $Operation.Stage = [System.IO.Path]::Combine(
      $Operation.Parent,
      ($Operation.TemporaryPrefix + [guid]::NewGuid().ToString("N").Substring(0, 8))
    )
    if (Test-Path -LiteralPath $Operation.Stage) {
      throw "Generated staging path already exists: $($Operation.Stage)"
    }
    Copy-DirectoryContents `
      -SourcePath $Operation.Source `
      -DestinationPath $Operation.Stage

    $StagedValidation = [System.IO.Path]::Combine(
      $Operation.Stage,
      $Operation.ValidationRelativePath
    )
    if (-not (Test-Path -LiteralPath $StagedValidation -PathType Leaf)) {
      throw "Staged $($Operation.Name) is invalid: $StagedValidation is missing."
    }
    $SourceValidation = [System.IO.Path]::Combine(
      $Operation.Source,
      $Operation.ValidationRelativePath
    )
    $SourceValidationHash = (Get-FileHash -LiteralPath $SourceValidation -Algorithm SHA256).Hash
    $StagedValidationHash = (Get-FileHash -LiteralPath $StagedValidation -Algorithm SHA256).Hash
    if ($SourceValidationHash -ne $StagedValidationHash) {
      throw "Staged $($Operation.Name) failed validation hash comparison."
    }
    $SourceStats = Get-TreeStats -Path $Operation.Source
    $StagedStats = Get-TreeStats -Path $Operation.Stage
    if (
      $SourceStats.Files -ne $StagedStats.Files -or
      $SourceStats.Directories -ne $StagedStats.Directories
    ) {
      throw "Staged $($Operation.Name) has an incomplete file tree."
    }
  }

  foreach ($Operation in $Operations) {
    $Operation.HadExisting = Test-Path -LiteralPath $Operation.Destination -PathType Container
    if ($Operation.HadExisting) {
      $Operation.Backup = [System.IO.Path]::Combine(
        $Operation.Parent,
        $Operation.BackupPrefix + (Get-Date -Format "yyyyMMdd-HHmmss") + "-" +
        [guid]::NewGuid().ToString("N").Substring(0, 8)
      )
      [System.IO.Directory]::Move($Operation.Destination, $Operation.Backup)
    }

    [System.IO.Directory]::Move($Operation.Stage, $Operation.Destination)
    $Operation.Swapped = $true
    $FinalValidation = [System.IO.Path]::Combine(
      $Operation.Destination,
      $Operation.ValidationRelativePath
    )
    if (-not (Wait-LiteralPath -Path $FinalValidation -PathType "Leaf")) {
      throw "Installed $($Operation.Name) is missing validation file: $FinalValidation"
    }
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
        [System.IO.Directory]::Move($Operation.Backup, $Operation.Destination)
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
