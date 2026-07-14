# Encoding: keep this file as UTF-8 with BOM for Windows PowerShell 5.1.
$ErrorActionPreference = "Stop"

if ($PSVersionTable.PSVersion.Major -ne 5) {
  throw "This regression must run in Windows PowerShell 5.1"
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$UpdateScript = Join-Path $RepoRoot "update-library.ps1"
$Root = [System.IO.Path]::Combine(
  $env:RUNNER_TEMP,
  "OneDrive",
  "Документы",
  "Альянс"
)
$Passport = Join-Path $Root "00_Паспорт_рабочего_места\Паспорт_рабочего_места.md"
$Roles = Join-Path $Root "01_Роль_и_траектория\Мои_роли_RL.md"
$Rhythm = Join-Path $Root "02_Рабочий_ритм_и_план_работ\Рабочий_ритм.md"
$LibraryRole = Join-Path $Root "03_Библиотека_роли"
$OpenStandard = Join-Path $LibraryRole "01_Открытый_стандарт"
$Library = Join-Path $OpenStandard "Свод_знаний_репозиторий"

foreach ($Directory in @(
  (Split-Path -Parent $Passport),
  (Split-Path -Parent $Roles),
  (Split-Path -Parent $Rhythm),
  $Library
)) {
  New-Item -ItemType Directory -Path $Directory -Force | Out-Null
}

Set-Content -LiteralPath $Passport -Value "passport-owner-data" -Encoding UTF8
Set-Content -LiteralPath $Roles -Value "role-owner-data" -Encoding UTF8
Set-Content -LiteralPath $Rhythm -Value "rhythm-owner-data" -Encoding UTF8
Set-Content -LiteralPath (Join-Path $Library ".keep") -Value "legacy-placeholder" -Encoding UTF8

$Before = @{}
foreach ($File in @($Passport, $Roles, $Rhythm)) {
  $Before[$File] = (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash
}

& $UpdateScript -Target $Root -LibraryOnly -DryRun
if (-not (Test-Path -LiteralPath (Join-Path $Library ".keep") -PathType Leaf)) {
  throw "DryRun changed the existing legacy destination"
}

& $UpdateScript -Target $Root -LibraryOnly -DryRun -CheckWriteAccess
if (-not (Test-Path -LiteralPath (Join-Path $Library ".keep") -PathType Leaf)) {
  throw "Write preflight changed the existing legacy destination"
}
$PreflightLeftovers = @(Get-ChildItem -LiteralPath $OpenStandard -Force |
  Where-Object { $_.Name -like "_aw-*" })
if ($PreflightLeftovers.Count -ne 0) {
  throw "Write preflight left temporary files or directories"
}

$BlockedRoot = [System.IO.Path]::Combine(
  $env:RUNNER_TEMP,
  "OneDrive",
  "Ограниченный контур",
  "Альянс"
)
$BlockedLibraryRole = Join-Path $BlockedRoot "03_Библиотека_роли"
New-Item -ItemType Directory -Path $BlockedLibraryRole -Force | Out-Null
$BlockedOpenStandard = Join-Path $BlockedLibraryRole "01_Открытый_стандарт"
Set-Content -LiteralPath $BlockedOpenStandard -Value "path-collision" -Encoding UTF8
$BlockedPreflightFailed = $false
try {
  & $UpdateScript -Target $BlockedRoot -LibraryOnly -DryRun -CheckWriteAccess
}
catch {
  $BlockedPreflightFailed = $true
}
if (-not $BlockedPreflightFailed) {
  throw "Write preflight unexpectedly succeeded against a blocked parent path"
}
if (-not (Test-Path -LiteralPath $BlockedOpenStandard -PathType Leaf)) {
  throw "Failed write preflight changed the blocked parent path"
}

& $UpdateScript -Target $Root -LibraryOnly
foreach ($Required in @(
  (Join-Path $Library "VERSION.json"),
  (Join-Path $Library "КАРТА_СВОДА.md"),
  (Join-Path $Library "Статьи\KA5\README.md")
)) {
  if (-not (Test-Path -LiteralPath $Required -PathType Leaf)) {
    throw "Required library file is missing: $Required"
  }
}
if (Test-Path -LiteralPath (Join-Path $Library ".keep")) {
  throw "Legacy placeholder survived a successful library replacement"
}

if (Test-Path -LiteralPath (Join-Path $OpenStandard "Система_Альянса")) {
  throw "LibraryOnly changed the Alliance system layer"
}

foreach ($File in @($Passport, $Roles, $Rhythm)) {
  $After = (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash
  if ($Before[$File] -ne $After) {
    throw "Owner file changed: $File"
  }
}

$DestinationVersion = Join-Path $Library "VERSION.json"
$DestinationHash = (Get-FileHash -LiteralPath $DestinationVersion -Algorithm SHA256).Hash
$SourceVersion = Join-Path $RepoRoot "knowledge-base\VERSION.json"
$SourceBackup = "$SourceVersion.test-backup"
Move-Item -LiteralPath $SourceVersion -Destination $SourceBackup
$FailedAsExpected = $false
try {
  & $UpdateScript -Target $Root -LibraryOnly
}
catch {
  $FailedAsExpected = $true
}
finally {
  Move-Item -LiteralPath $SourceBackup -Destination $SourceVersion
}

if (-not $FailedAsExpected) {
  throw "Update unexpectedly succeeded with an invalid source"
}

$DestinationHashAfterFailure = (
  Get-FileHash -LiteralPath $DestinationVersion -Algorithm SHA256
).Hash
if ($DestinationHash -ne $DestinationHashAfterFailure) {
  throw "Existing library changed after a failed update"
}

$Leftovers = @(Get-ChildItem -LiteralPath $OpenStandard -Force |
  Where-Object {
    $_.Name -like "_aw-*" -or
    $_.Name -like "_kb-s-*" -or
    $_.Name -like "_kb-b-*" -or
    $_.Name -like "_sys-s-*" -or
    $_.Name -like "_sys-b-*" -or
    $_.Name -like ".alliance-*-stage-*" -or
    $_.Name -like ".alliance-*-backup-*"
  })
if ($Leftovers.Count -ne 0) {
  throw "Temporary staging or backup directories remain after update"
}

Write-Host "Windows PowerShell 5.1 Cyrillic-path library update passed."
