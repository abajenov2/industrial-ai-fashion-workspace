# Encoding: keep this file as UTF-8 with BOM for Windows PowerShell 5.1.
$ErrorActionPreference = "Stop"

if ($PSVersionTable.PSVersion.Major -ne 5) {
  throw "This regression must run in Windows PowerShell 5.1"
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$UpdateScript = Join-Path $RepoRoot "update-library.ps1"
$Root = [System.IO.Path]::Combine(
  $env:RUNNER_TEMP,
  "CodexSandbox",
  "OneDrive",
  "Документы",
  "Рабочее место Ланы",
  "Альянс"
)
$Passport = Join-Path $Root "00_Паспорт_рабочего_места\Паспорт_рабочего_места.md"
$Roles = Join-Path $Root "01_Роль_и_траектория\Мои_роли_RL.md"
$Rhythm = Join-Path $Root "02_Рабочий_ритм_и_план_работ\Рабочий_ритм.md"
$OpenStandard = Join-Path $Root "03_Библиотека_роли\01_Открытый_стандарт"
$Library = Join-Path $OpenStandard "Свод_знаний_репозиторий"

foreach ($Directory in @(
  (Split-Path -Parent $Passport),
  (Split-Path -Parent $Roles),
  (Split-Path -Parent $Rhythm),
  $Library
)) {
  [System.IO.Directory]::CreateDirectory($Directory) | Out-Null
}

Set-Content -LiteralPath $Passport -Value "passport-owner-data" -Encoding UTF8
Set-Content -LiteralPath $Roles -Value "role-owner-data" -Encoding UTF8
Set-Content -LiteralPath $Rhythm -Value "rhythm-owner-data" -Encoding UTF8
Set-Content -LiteralPath (Join-Path $Library ".keep") -Value "legacy-placeholder" -Encoding UTF8

$Before = @{}
foreach ($File in @($Passport, $Roles, $Rhythm)) {
  $Before[$File] = (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash
}

$OneDriveWarnings = @()
& $UpdateScript `
  -Target $Root `
  -LibraryOnly `
  -DryRun `
  -CheckWriteAccess `
  -WarningVariable OneDriveWarnings
if (-not (($OneDriveWarnings | Out-String) -match "Target is inside OneDrive")) {
  throw "OneDrive target warning was not emitted"
}
if (-not (Test-Path -LiteralPath (Join-Path $Library ".keep") -PathType Leaf)) {
  throw "DryRun write preflight changed the legacy library"
}

& $UpdateScript -Target $Root -LibraryOnly
if (-not (Test-Path -LiteralPath (Join-Path $Library "VERSION.json") -PathType Leaf)) {
  throw "VERSION.json is missing after the staged update"
}
if (Test-Path -LiteralPath (Join-Path $Library ".keep")) {
  throw "The existing library was not replaced"
}

foreach ($File in @($Passport, $Roles, $Rhythm)) {
  $After = (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash
  if ($Before[$File] -ne $After) {
    throw "Owner file changed: $File"
  }
}

$TemporaryLeftovers = @(Get-ChildItem -LiteralPath $OpenStandard -Force |
  Where-Object {
    $_.Name -like "_aw-*" -or
    $_.Name -like "_kb-s-*" -or
    $_.Name -like "_kb-b-*"
  })
if ($TemporaryLeftovers.Count -ne 0) {
  throw "Temporary staging, backup or preflight directories remain"
}

$BlockedRoot = [System.IO.Path]::Combine(
  $env:RUNNER_TEMP,
  "CodexSandbox",
  "OneDrive",
  "Ограниченный путь",
  "Альянс"
)
$BlockedLibraryRole = Join-Path $BlockedRoot "03_Библиотека_роли"
[System.IO.Directory]::CreateDirectory($BlockedLibraryRole) | Out-Null
$BlockedParent = Join-Path $BlockedLibraryRole "01_Открытый_стандарт"
Set-Content -LiteralPath $BlockedParent -Value "blocked-parent" -Encoding UTF8

$FailedSafely = $false
$BlockedFailureMessage = ""
try {
  & $UpdateScript -Target $BlockedRoot -LibraryOnly -DryRun -CheckWriteAccess
}
catch {
  $FailedSafely = $true
  $BlockedFailureMessage = $_.Exception.Message
}
if (-not $FailedSafely) {
  throw "Preflight unexpectedly succeeded against a blocked parent"
}
if ($BlockedFailureMessage -notmatch "short ASCII path outside OneDrive") {
  throw "Blocked OneDrive preflight did not return safe migration guidance"
}
if (-not (Test-Path -LiteralPath $BlockedParent -PathType Leaf)) {
  throw "Failed preflight changed the blocked parent"
}

Write-Host "Windows PowerShell 5.1 OneDrive staging preflight regression passed."
