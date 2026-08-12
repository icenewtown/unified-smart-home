# Smart Home GitHub auto-sync
# Daily task: rebuild a sanitized publish copy from the source project, commit and push.
param(
    [string]$SourceRoot = 'E:\smart_home',
    [string]$RepoUrl = 'git@github.com:icenewtown/unified-smart-home.git',
    [switch]$ForcePush
)
$ErrorActionPreference = 'Continue'
$env:GIT_TERMINAL_PROMPT = '0'
$PublishRoot = Join-Path $env:LOCALAPPDATA 'SmartHomePublish'
$PublishGit = Join-Path $PublishRoot 'publish'
$LogFile = Join-Path $PublishRoot 'sync.log'
$TokenFile = Join-Path $PublishRoot 'gh-token.txt'
$IdentityName = 'icenewtown'
$IdentityEmail = 'icenewtown@users.noreply.github.com'

function Write-Log {
    param([string]$Message)
    $line = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -LiteralPath $LogFile -Value $line -Encoding UTF8
    Write-Output $line
}

function Invoke-GitRetry {
    param(
        [string]$Label,
        [scriptblock]$Action,
        [int]$MaxAttempts = 3,
        [int]$DelaySec = 20
    )
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        $code = & $Action
        if ($code -eq 0) { return 0 }
        if ($attempt -lt $MaxAttempts) {
            Write-Log ("{0} failed (attempt {1}/{2}), retrying in {3}s" -f $Label, $attempt, $MaxAttempts, $DelaySec)
            Start-Sleep -Seconds $DelaySec
        }
    }
    Write-Log ("{0} failed after {1} attempts" -f $Label, $MaxAttempts)
    return 1
}

try {
    New-Item -ItemType Directory -Path $PublishRoot -Force -ErrorAction Stop | Out-Null
    New-Item -ItemType Directory -Path $PublishGit -Force -ErrorAction Stop | Out-Null

    Get-ChildItem -LiteralPath $PublishGit -Force |
        Where-Object { $_.Name -ne '.git' } |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

    $items = @('README.md','LICENSE','CHANGELOG.md','docker-compose.yml','AGENTS.md','.gitignore','.gitattributes','docs','scripts','templates')
    foreach ($item in $items) {
        $src = Join-Path $SourceRoot $item
        if (Test-Path -LiteralPath $src) {
            Copy-Item -LiteralPath $src -Destination $PublishGit -Recurse -Force -ErrorAction Stop
        }
    }
    New-Item -ItemType Directory -Path (Join-Path $PublishGit 'config') -Force -ErrorAction Stop | Out-Null
    Copy-Item -LiteralPath (Join-Path $SourceRoot 'config\.gitkeep') -Destination (Join-Path $PublishGit 'config\.gitkeep') -Force -ErrorAction Stop

    $patterns = @('ghp_[A-Za-z0-9]+','github_pat_[A-Za-z0-9_]+','gho_[A-Za-z0-9]+')
    $PatternsFile = Join-Path $PublishRoot 'sensitive-patterns.txt'
    if (Test-Path -LiteralPath $PatternsFile) {
        $custom = Get-Content -LiteralPath $PatternsFile |
            Where-Object { $_.Trim() -and -not $_.Trim().StartsWith('#') }
        if ($custom) { $patterns = @($patterns + $custom) }
    }
    $hits = Get-ChildItem -LiteralPath $PublishGit -Recurse -File -Force |
        Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.Name -ne 'sync-github.ps1' } |
        Select-String -Pattern $patterns -ErrorAction SilentlyContinue
    if ($hits) {
        Write-Log ('ABORT: sensitive content detected at {0}:{1}' -f $hits[0].Path, $hits[0].LineNumber)
        exit 1
    }

    $authArgs = @()
    if ($RepoUrl.StartsWith('https://')) {
        $ghExe = ''
        $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
        if ($ghCmd) { $ghExe = $ghCmd.Source }
        if (-not $ghExe -and (Test-Path -LiteralPath 'C:\Program Files\GitHub CLI\gh.exe')) {
            $ghExe = 'C:\Program Files\GitHub CLI\gh.exe'
        }
        $token = ''
        if ($ghExe) {
            $token = (& $ghExe auth token 2>$null).Trim()
        }
        if (-not $token -and (Test-Path -LiteralPath $TokenFile)) {
            $token = (Get-Content -Raw -LiteralPath $TokenFile).Trim()
        }
        if (-not $token) {
            Write-Log 'ERROR: no token available (gh auth or token file) for HTTPS push'
            exit 1
        }
        $b64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$IdentityName`:$token"))
        $authArgs = @('-c','credential.helper=','-c',"http.extraheader=Authorization: Basic $b64")
    }

    if (-not (Test-Path -LiteralPath (Join-Path $PublishGit '.git'))) {
        git -C $PublishGit init -b main 2>$null | Out-Null
    }
    git -C $PublishGit remote remove origin 2>$null
    git -C $PublishGit remote add origin $RepoUrl 2>$null
    if ($LASTEXITCODE -ne 0) {
        git -C $PublishGit remote set-url origin $RepoUrl 2>$null
    }
    git -C $PublishGit config user.name $IdentityName 2>$null
    git -C $PublishGit config user.email $IdentityEmail 2>$null
    git -C $PublishGit config core.autocrlf false 2>$null

    git -C $PublishGit add -A 2>$null
    $status = git -C $PublishGit status --porcelain 2>$null
    if ($status) {
        git -C $PublishGit commit -m ('auto sync: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm')) 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Log 'ERROR: commit failed'
            exit 1
        }
        Write-Log ('committed {0} changed path(s)' -f @($status).Count)
    } else {
        Write-Log 'no changes'
    }

    git -C $PublishGit rebase --quit 2>$null
    if (-not $ForcePush) {
        $pullOk = Invoke-GitRetry -Label 'pull --rebase' -Action {
            & git @authArgs -C $PublishGit pull --rebase origin main 2>$null | Out-Null
            return $LASTEXITCODE
        }
        if ($pullOk -ne 0) {
            Write-Log 'ERROR: pull failed after retries'
            exit 1
        }
    } else {
        Write-Log 'force push mode: skip pull'
    }
    $pushArgs = @('push')
    if ($ForcePush) { $pushArgs += '--force' }
    $pushOk = Invoke-GitRetry -Label 'push' -Action {
        & git @authArgs -C $PublishGit @pushArgs origin main 2>$null | Out-Null
        return $LASTEXITCODE
    }
    if ($pushOk -ne 0) {
        Write-Log 'ERROR: push failed after retries'
        exit 1
    }
    Write-Log 'pushed OK'
} catch {
    Write-Log ('ERROR: {0}' -f $_.Exception.Message)
    exit 1
}



