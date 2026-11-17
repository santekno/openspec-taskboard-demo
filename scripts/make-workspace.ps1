# Creates your own GitHub copy of this repo (all demo/*, greenfield/*, integration/* branches) for a rehearsal
# or the live demo, so PRs and merges never touch santekno/openspec-taskboard-demo.
# Usage: powershell -ExecutionPolicy Bypass -File scripts\make-workspace.ps1 [-Name taskboard-demo] [-Public]
param([string]$Name = 'taskboard-demo', [switch]$Public)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
function Run { & $args[0] $args[1..($args.Count - 1)]; if ($LASTEXITCODE -ne 0) { throw "Failed: $($args -join ' ')" } }

$remotes = git remote
if ($remotes -notcontains 'upstream') { Run git remote rename origin upstream }
Run git fetch -q upstream
Run git switch -q main

$vis = if ($Public) { '--public' } else { '--private' }
Run gh repo create $Name $vis --source . --remote origin
Run git push -u origin main
foreach ($p in 'demo', 'greenfield', 'integration') {
  Run git push origin "refs/remotes/upstream/$p/*:refs/heads/$p/*"
}

$count = (git ls-remote --heads origin 'demo/*' 'greenfield/*' 'integration/*' | Measure-Object).Count
Write-Host ''
Write-Host "Your copy: $(git remote get-url origin)"
Write-Host "Branches:  main + $count scenario branches"
Write-Host 'Next:      powershell -ExecutionPolicy Bypass -File scripts\preflight.ps1; then scripts\check.ps1'
