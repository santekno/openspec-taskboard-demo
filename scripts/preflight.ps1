# Checks the presenter laptop before the demo (Windows PowerShell 5.1+ or PowerShell 7+).
# Usage: powershell -ExecutionPolicy Bypass -File scripts\preflight.ps1
$OnWindows = $env:OS -eq 'Windows_NT'
$ok = $true
function Need([string]$Name, [string[]]$VersionArgs) {
  $cmd = $Name
  if ($OnWindows -and (Get-Command "$Name.cmd" -ErrorAction SilentlyContinue)) { $cmd = "$Name.cmd" }
  if (Get-Command $cmd -ErrorAction SilentlyContinue) {
    $v = (& $cmd @VersionArgs 2>&1 | Select-Object -First 1)
    Write-Host ('  [ok] {0,-9} {1}' -f $Name, $v)
  } else {
    Write-Host ('  [x]  {0,-9} missing' -f $Name)
    $script:ok = $false
  }
}

Write-Host 'Tools:'
Need node @('--version')
Need go @('version')
Need git @('--version')
Need gh @('--version')
Need openspec @('--version')
Need claude @('--version')

if (Get-Command node -ErrorAction SilentlyContinue) {
  node -e 'const [a,b]=process.versions.node.split(''.'').map(Number);process.exit(a>22||(a===22&&b>=12)?0:1)' 2>$null
  if ($LASTEXITCODE -ne 0) { Write-Host "  [x]  Node $(node -p 'process.versions.node'): OpenSpec 1.16 needs >= 22.12"; $ok = $false }
}

Write-Host 'GitHub:'
if (Get-Command gh -ErrorAction SilentlyContinue) {
  gh auth status *> $null
  if ($LASTEXITCODE -eq 0) { Write-Host '  [ok] gh logged in' } else { Write-Host '  [x]  run: gh auth login'; $ok = $false }
}

Write-Host 'Model routing:'
if ($env:CLAUDE_CODE_SUBAGENT_MODEL) {
  Write-Host "  [x]  CLAUDE_CODE_SUBAGENT_MODEL=$($env:CLAUDE_CODE_SUBAGENT_MODEL) overrides every agent model; run: Remove-Item Env:CLAUDE_CODE_SUBAGENT_MODEL"
  $ok = $false
} else { Write-Host '  [ok] CLAUDE_CODE_SUBAGENT_MODEL is unset' }

if ($OnWindows) {
  Write-Host 'Windows:'
  if (Get-Command bash -ErrorAction SilentlyContinue) { Write-Host '  [ok] bash found (Git Bash): Claude Code can use its Bash tool' }
  else { Write-Host '  [!]  no bash on PATH: Claude Code will use PowerShell; install Git for Windows for the Bash tool' }
  $acrlf = (git config --get core.autocrlf) 2>$null
  if ($acrlf -eq 'true') { Write-Host '  [!]  core.autocrlf=true; .gitattributes keeps *.sh as LF, but "input" is safer' }
}

if ($ok) { Write-Host 'Ready for the demo.' } else { Write-Host 'Fix the items marked [x].'; exit 1 }
