# Runs every check CI runs (Windows PowerShell 5.1+ or PowerShell 7+).
# Usage: powershell -ExecutionPolicy Bypass -File scripts\check.ps1 [-NoE2e]
param([switch]$NoE2e)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$OnWindows = $env:OS -eq 'Windows_NT'
$Npm = if ($OnWindows) { 'npm.cmd' } else { 'npm' }
$OpenSpec = if ($OnWindows) { 'openspec.cmd' } else { 'openspec' }

function Invoke-In([string]$Dir, [scriptblock]$Block) {
  Push-Location (Join-Path $Root $Dir)
  try {
    & $Block
    if ($LASTEXITCODE -ne 0) { throw "Failed in $Dir (exit $LASTEXITCODE)" }
  } finally { Pop-Location }
}
function Test-Url([string]$Url) {
  try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 2 $Url | Out-Null; return $true } catch { return $false }
}

if (-not (Test-Path (Join-Path $Root 'apps/api'))) {
  Write-Host 'No apps/ yet (greenfield start): only validating OpenSpec.'
  if (Get-Command $OpenSpec -ErrorAction SilentlyContinue) {
    $env:OPENSPEC_TELEMETRY = '0'
    Push-Location $Root; try { & $OpenSpec validate --all --strict --no-interactive } finally { Pop-Location }
  }
  exit 0
}

# go test -race needs cgo (a C compiler). Most Windows machines have none, so -race is used only when gcc exists.
$Race = @()
if (-not $OnWindows -or (Get-Command gcc -ErrorAction SilentlyContinue)) { $Race = @('-race') }
else { Write-Host '   (no gcc found: running go test without -race)' }

Write-Host '== go vet + go test'
Invoke-In 'apps/api' { go vet ./...; if ($LASTEXITCODE -eq 0) { go test @Race ./... } }

if (Test-Path (Join-Path $Root 'apps/users-auth')) {
  Write-Host '== users-auth tests + contract test'
  Invoke-In 'apps/users-auth' { go test ./... }
  $env:USERS_AUTH_URL = 'http://localhost:8081'
  if (Test-Url 'http://localhost:8081/health') {
    Invoke-In 'apps/api' { go test -count=1 -run Contract ./internal/usersauth/ }
  } else {
    $Bin = Join-Path $Root ($(if ($OnWindows) { '.users-auth.exe' } else { '.users-auth.bin' }))
    Invoke-In 'apps/users-auth' { go build -o $Bin . }
    $Ua = Start-Process -FilePath $Bin -PassThru -NoNewWindow
    try {
      for ($i = 0; $i -lt 30 -and -not (Test-Url 'http://localhost:8081/health'); $i++) { Start-Sleep -Milliseconds 300 }
      Invoke-In 'apps/api' { go test -count=1 -run Contract ./internal/usersauth/ }
    } finally {
      Stop-Process -Id $Ua.Id -Force -ErrorAction SilentlyContinue
      Start-Sleep -Milliseconds 300
      Remove-Item $Bin -Force -ErrorAction SilentlyContinue
    }
  }
}

Write-Host '== web typecheck + unit tests'
Invoke-In 'apps/web' { & $Npm run --silent typecheck; if ($LASTEXITCODE -eq 0) { & $Npm test --silent } }

if (-not $NoE2e) {
  Write-Host '== e2e (Playwright)'
  Invoke-In 'apps/web' { & $Npm run --silent e2e }
}

if ((Test-Path (Join-Path $Root 'openspec')) -and (Get-Command $OpenSpec -ErrorAction SilentlyContinue)) {
  Write-Host '== openspec validate'
  $env:OPENSPEC_TELEMETRY = '0'
  Invoke-In '.' { & $OpenSpec validate --all --strict }
}
Write-Host 'All checks passed.'
