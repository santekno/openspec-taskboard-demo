# Runs the whole app locally with one command (Windows PowerShell 5.1+ or PowerShell 7+):
#   API (Go) on :8080, web (Vite) on :5173, and users-auth on :8081 when the branch has it.
# Ctrl+C stops everything. Usage: powershell -ExecutionPolicy Bypass -File scripts\dev.ps1
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$OnWindows = $env:OS -eq 'Windows_NT'
$Npm = if ($OnWindows) { 'npm.cmd' } else { 'npm' }
$HasUsersAuth = Test-Path (Join-Path $Root 'apps/users-auth')

if (-not (Test-Path (Join-Path $Root 'apps/api'))) {
  Write-Host 'No apps/ on this branch yet (greenfield start). Run /opsx:apply first.'
  exit 1
}

function Test-Port([int]$Port) {
  $c = New-Object System.Net.Sockets.TcpClient
  try { $c.Connect('127.0.0.1', $Port); return $true } catch { return $false } finally { $c.Close() }
}
function Wait-Url([string]$Url) {
  for ($i = 0; $i -lt 60; $i++) {
    try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 2 $Url | Out-Null; return } catch { Start-Sleep -Seconds 1 }
  }
  throw "Timed out waiting for $Url"
}
function Stop-Tree([System.Diagnostics.Process]$P) {
  if (-not $P -or $P.HasExited) { return }
  if ($OnWindows) { & taskkill.exe /T /F /PID $P.Id 2>&1 | Out-Null }
  else { & pkill -TERM -P $P.Id 2>$null; Stop-Process -Id $P.Id -Force -ErrorAction SilentlyContinue }
}

$ports = @(8080, 5173); if ($HasUsersAuth) { $ports += 8081 }
foreach ($p in $ports) { if (Test-Port $p) { Write-Host "Port $p is already in use. Stop that process first."; exit 1 } }

if (-not (Test-Path (Join-Path $Root 'apps/web/node_modules'))) {
  Write-Host '== installing web dependencies (npm ci)'
  Push-Location (Join-Path $Root 'apps/web'); try { & $Npm ci } finally { Pop-Location }
}

$procs = @()
try {
  if ($HasUsersAuth) {
    $procs += Start-Process go -ArgumentList 'run', '.' -WorkingDirectory (Join-Path $Root 'apps/users-auth') -NoNewWindow -PassThru
    Wait-Url 'http://localhost:8081/health'
  }
  $procs += Start-Process go -ArgumentList 'run', '.' -WorkingDirectory (Join-Path $Root 'apps/api') -NoNewWindow -PassThru
  $procs += Start-Process $Npm -ArgumentList 'run', 'dev' -WorkingDirectory (Join-Path $Root 'apps/web') -NoNewWindow -PassThru
  Wait-Url 'http://localhost:8080/api/health'
  Wait-Url 'http://localhost:5173/'

  Write-Host ''
  Write-Host '  Web   http://localhost:5173'
  Write-Host '  API   http://localhost:8080/api/health'
  if ($HasUsersAuth) { Write-Host '  Users http://localhost:8081/users/u-1' }
  Write-Host '  Ctrl+C stops everything.'
  Write-Host ''
  while ($true) {
    foreach ($p in $procs) { if ($p.HasExited) { throw "A process exited (pid $($p.Id)); stopping the rest." } }
    Start-Sleep -Seconds 1
  }
} finally {
  foreach ($p in $procs) { Stop-Tree $p }
}
