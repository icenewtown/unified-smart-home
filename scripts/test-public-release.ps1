# Verify that a publishable copy contains no known secret material.
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRoot,
    [string]$PatternsFile = (Join-Path $env:LOCALAPPDATA 'SmartHomePublish\sensitive-patterns.txt'),
    [switch]$SkipCompose
)

$ErrorActionPreference = 'Stop'
$TargetRoot = (Resolve-Path -LiteralPath $TargetRoot).Path
if (-not (Test-Path -LiteralPath $PatternsFile)) {
    throw "Sensitive-patterns file is required but missing: $PatternsFile"
}

# Split token prefixes so this validator does not trigger on its own source code.
$patterns = @(
    ('gh' + 'p_' + '[A-Za-z0-9]+'),
    ('gho' + '_' + '[A-Za-z0-9]+'),
    ('github' + '_pat_' + '[A-Za-z0-9_]+'),
    ('sk' + '-[A-Za-z0-9_-]{20,}'),
    ('AKIA' + '[A-Z0-9]{16}'),
    ('-----BEGIN [A-Z ]*PRIVATE KEY-----')
)
$patterns += Get-Content -LiteralPath $PatternsFile |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') }

$excludedNames = @('.git', 'config', 'backups', '.env', 'secrets.yaml')
$files = Get-ChildItem -LiteralPath $TargetRoot -Recurse -File -Force |
    Where-Object {
        $relative = $_.FullName.Substring($TargetRoot.Length).TrimStart('\', '/')
        $parts = $relative -split '[\\/]'
        -not ($parts | Where-Object { $excludedNames -contains $_ })
    }

$hits = $files | Select-String -Pattern $patterns -ErrorAction SilentlyContinue
if ($hits) {
    $first = $hits | Select-Object -First 1
    throw "Sensitive content detected: $($first.Path):$($first.LineNumber)"
}

if (-not $SkipCompose -and (Test-Path -LiteralPath (Join-Path $TargetRoot 'docker-compose.yml'))) {
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if ($docker) {
        & docker compose -f (Join-Path $TargetRoot 'docker-compose.yml') config --quiet
        if ($LASTEXITCODE -ne 0) { throw 'docker compose config validation failed' }
    } else {
        Write-Warning 'Docker is unavailable; skipped docker compose config validation.'
    }
}
Write-Output "PASS: publishable content verified at $TargetRoot"
