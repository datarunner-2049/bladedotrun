# BLADE.RUN Setup Script — Windows
# Run with: powershell -ExecutionPolicy Bypass -File setup.ps1

$banner = @"
  ____  _      _    ____  _____   ____  _   _ _   _
 | __ )| |    / \  |  _ \| ____| |  _ \| | | | \ | |
 |  _ \| |   / _ \ | | | |  _|   | |_) | | | |  \| |
 | |_) | |__/ ___ \| |_| | |___  |  _ <| |_| | |\  |
 |____/|____/_/   \_|____/|_____| |_| \_\\___/|_| \_|

 SYSTEM SETUP :: WINDOWS :: v1.0
 ================================
"@

Write-Host $banner -ForegroundColor Cyan

# ── Verify winget is available ────────────────────────────────────────────────
Write-Host "[INIT] Checking winget availability..." -ForegroundColor Yellow

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] winget not found." -ForegroundColor Red
    Write-Host "        Install App Installer from the Microsoft Store:" -ForegroundColor Gray
    Write-Host "        https://aka.ms/getwinget" -ForegroundColor Gray
    exit 1
}

$wingetVersion = winget --version
Write-Host "[OK]    winget $wingetVersion detected" -ForegroundColor Green
Write-Host ""

# ── App manifest ──────────────────────────────────────────────────────────────
$apps = @(
    @{ Name = "Google Chrome";  Id = "Google.Chrome"      },
    @{ Name = "Steam";          Id = "Valve.Steam"         },
    @{ Name = "Claude";         Id = "Anthropic.Claude"    },
    @{ Name = "Discord";        Id = "Discord.Discord"     }
)

$results = @()

# ── Install loop ──────────────────────────────────────────────────────────────
foreach ($app in $apps) {
    Write-Host "[INSTALL] $($app.Name)..." -ForegroundColor Cyan

    winget install --id $app.Id -e --silent `
        --accept-source-agreements `
        --accept-package-agreements | Out-Null

    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
        # Exit code -1978335189 (0x8A150011) = already installed, treat as success
        Write-Host "[OK]      $($app.Name) ready" -ForegroundColor Green
        $results += @{ Name = $app.Name; Status = "OK" }
    } else {
        Write-Host "[FAIL]    $($app.Name) — exit code $LASTEXITCODE" -ForegroundColor Red
        $results += @{ Name = $app.Name; Status = "FAIL" }
    }
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "─────────────────────────────────" -ForegroundColor DarkCyan
Write-Host " INSTALLATION SUMMARY" -ForegroundColor Cyan
Write-Host "─────────────────────────────────" -ForegroundColor DarkCyan

$ok   = 0
$fail = 0

foreach ($r in $results) {
    if ($r.Status -eq "OK") {
        Write-Host "  [OK]   $($r.Name)" -ForegroundColor Green
        $ok++
    } else {
        Write-Host "  [FAIL] $($r.Name)" -ForegroundColor Red
        $fail++
    }
}

Write-Host "─────────────────────────────────" -ForegroundColor DarkCyan
Write-Host "  $ok succeeded · $fail failed" -ForegroundColor White
Write-Host ""

if ($fail -eq 0) {
    Write-Host " ALL SYSTEMS GO — SETUP COMPLETE" -ForegroundColor Green
} else {
    Write-Host " SETUP COMPLETE WITH ERRORS — check failed apps above" -ForegroundColor Yellow
}

Write-Host ""
