# Single source of truth for app version: repo-root VERSION file.
#
# Usage:
#   .\scripts\app_version.ps1 print
#   .\scripts\app_version.ps1 build-name
#   .\scripts\app_version.ps1 build-number
#   .\scripts\app_version.ps1 flutter-args
#   .\scripts\app_version.ps1 sync
#   .\scripts\app_version.ps1 set 1.2.0+3
#   .\scripts\app_version.ps1 bump major|minor|patch|build
#
# Bump rules:
#   major  1.2.3+5 → 2.0.0+5   (build unchanged)
#   minor  1.2.3+5 → 1.3.0+5
#   patch  1.2.3+5 → 1.2.4+5
#   build  1.2.3+5 → 1.2.3+6   (only this bumps +N / Android versionCode)

param(
  [Parameter(Position = 0)]
  [ValidateSet('print', 'build-name', 'build-number', 'flutter-args', 'sync', 'set', 'bump')]
  [string]$Command = 'print',

  [Parameter(Position = 1)]
  [string]$Value
)

$ErrorActionPreference = 'Stop'

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$VersionFile = Join-Path $ProjectRoot 'VERSION'
$PubspecFile = Join-Path $ProjectRoot 'pubspec.yaml'

function Read-RawVersion {
  if (-not (Test-Path $VersionFile)) {
    Write-Error "VERSION file not found: $VersionFile"
  }
  $raw = (Get-Content -Raw $VersionFile).Trim()
  if ([string]::IsNullOrWhiteSpace($raw)) {
    Write-Error "VERSION file is empty: $VersionFile"
  }
  if ($raw -notmatch '^\d+\.\d+\.\d+(\+\d+)?$') {
    Write-Error "Invalid VERSION '$raw' (expected x.y.z or x.y.z+build, e.g. 1.2.0+1)"
  }
  return $raw
}

function Get-BuildName([string]$Raw) {
  return ($Raw -split '\+', 2)[0]
}

function Get-BuildNumber([string]$Raw) {
  $parts = $Raw -split '\+', 2
  if ($parts.Length -gt 1 -and -not [string]::IsNullOrWhiteSpace($parts[1])) {
    return $parts[1]
  }
  return '1'
}

function Get-NormalizedVersion([string]$Raw) {
  return "$(Get-BuildName $Raw)+$(Get-BuildNumber $Raw)"
}

function Get-BumpedVersion([string]$Part) {
  $raw = Read-RawVersion
  $name = Get-BuildName $raw
  $number = [int](Get-BuildNumber $raw)
  $semver = $name.Split('.')
  $major = [int]$semver[0]
  $minor = [int]$semver[1]
  $patch = [int]$semver[2]
  $nextName = $name
  $nextNumber = $number

  switch ($Part) {
    'major' { $nextName = "$($major + 1).0.0" }
    'minor' { $nextName = "$major.$($minor + 1).0" }
    'patch' { $nextName = "$major.$minor.$($patch + 1)" }
    'build' { $nextNumber = $number + 1 }
    default { Write-Error "Unknown bump part: $Part (use major|minor|patch|build)" }
  }

  return "$nextName+$nextNumber"
}

function Sync-Pubspec([string]$Raw) {
  $normalized = Get-NormalizedVersion $Raw
  if (-not (Test-Path $PubspecFile)) {
    Write-Error "pubspec.yaml not found: $PubspecFile"
  }
  $lines = Get-Content -Path $PubspecFile
  $found = $false
  $updated = foreach ($line in $lines) {
    if ($line -match '^version:\s*') {
      $found = $true
      "version: $normalized"
    } else {
      $line
    }
  }
  if (-not $found) {
    Write-Error "No 'version:' line in pubspec.yaml"
  }
  $updated | Set-Content -Path $PubspecFile -Encoding utf8
  return $normalized
}

function Write-VersionFile([string]$Raw) {
  $normalized = Get-NormalizedVersion $Raw
  Set-Content -Path $VersionFile -Value $normalized
  return $normalized
}

function Apply-AndSync([string]$Next) {
  $previous = Get-NormalizedVersion (Read-RawVersion)
  $written = Write-VersionFile $Next
  $synced = Sync-Pubspec $written
  Write-Host "$previous → $synced"
}

switch ($Command) {
  'print' {
    Write-Output (Get-NormalizedVersion (Read-RawVersion))
  }
  'build-name' {
    Write-Output (Get-BuildName (Read-RawVersion))
  }
  'build-number' {
    Write-Output (Get-BuildNumber (Read-RawVersion))
  }
  'flutter-args' {
    $raw = Read-RawVersion
    $name = Get-BuildName $raw
    $number = Get-BuildNumber $raw
    $full = Get-NormalizedVersion $raw
    Write-Output "--build-name=$name --build-number=$number --dart-define=APP_VERSION=$full"
  }
  'sync' {
    $synced = Sync-Pubspec (Read-RawVersion)
    Write-Host "Synced pubspec.yaml version → $synced"
  }
  'set' {
    if ([string]::IsNullOrWhiteSpace($Value)) {
      Write-Error 'Usage: .\scripts\app_version.ps1 set <x.y.z[+build]>'
    }
    if ($Value -notmatch '^\d+\.\d+\.\d+(\+\d+)?$') {
      Write-Error "Invalid version '$Value' (expected x.y.z or x.y.z+build, e.g. 1.2.0+1)"
    }
    Apply-AndSync $Value
  }
  'bump' {
    if ([string]::IsNullOrWhiteSpace($Value)) {
      Write-Error 'Usage: .\scripts\app_version.ps1 bump major|minor|patch|build'
    }
    if ($Value -notin @('major', 'minor', 'patch', 'build')) {
      Write-Error "Unknown bump part: $Value (use major|minor|patch|build)"
    }
    Apply-AndSync (Get-BumpedVersion $Value)
  }
}
