# Prints Flutter --dart-define flags from a local KEY=VALUE env file.
# Missing file or empty values → prints nothing.
#
# Usage:
#   .\scripts\oauth_dart_defines.ps1
#   .\scripts\oauth_dart_defines.ps1 -EnvFile .\local.oauth.env

param(
  [string]$EnvFile = ""
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if ([string]::IsNullOrWhiteSpace($EnvFile)) {
  $EnvFile = Join-Path $root 'local.oauth.env'
}

if (-not (Test-Path -LiteralPath $EnvFile)) {
  return
}

$allowed = @(
  'GOOGLE_OAUTH_CLIENT_ID_DESKTOP',
  'GOOGLE_OAUTH_CLIENT_ID_ANDROID',
  'GOOGLE_OAUTH_CLIENT_ID'
)

$defines = New-Object System.Collections.Generic.List[string]
Get-Content -LiteralPath $EnvFile | ForEach-Object {
  $line = $_.Trim()
  if ([string]::IsNullOrWhiteSpace($line)) { return }
  if ($line.StartsWith('#')) { return }
  $eq = $line.IndexOf('=')
  if ($eq -lt 1) { return }
  $key = $line.Substring(0, $eq).Trim()
  $val = $line.Substring($eq + 1).Trim()
  if ($val.Length -ge 2) {
    $q = $val[0]
    if (($q -eq '"' -or $q -eq "'") -and $val[-1] -eq $q) {
      $val = $val.Substring(1, $val.Length - 2)
    }
  }
  if (-not ($allowed -contains $key)) { return }
  if ([string]::IsNullOrWhiteSpace($val)) { return }
  $defines.Add("--dart-define=$key=$val")
}

if ($defines.Count -gt 0) {
  Write-Output ($defines -join ' ')
}
