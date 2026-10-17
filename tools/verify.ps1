param([string]$GodotPath = "$PSScriptRoot/../.local/tools/Godot_v4.7.2-stable_win64_console.exe")
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$godot = (Resolve-Path -LiteralPath $GodotPath).Path
$logDir = Join-Path $repoRoot '.local/verification'
New-Item -ItemType Directory -Force $logDir | Out-Null
$version = & $godot --version
if ($LASTEXITCODE -ne 0 -or $version -notmatch '^4\.7\.2\.stable\.') {
    throw "Expected Godot 4.7.2 stable; found: $version"
}
function Invoke-GodotCheck([string]$Name, [string[]]$Arguments) {
    $logPath = Join-Path $logDir "$Name.log"
    & $godot --headless --path $repoRoot --log-file $logPath @Arguments 2>&1 | Tee-Object -FilePath "$logPath.console.txt"
    if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE" }
    if (Select-String -LiteralPath "$logPath.console.txt" -Pattern '(^|\s)(SCRIPT ERROR:|ERROR:|Parse Error:)' -Quiet) {
        throw "$Name emitted engine errors; see $logPath.console.txt"
    }
}
Invoke-GodotCheck 'import' @('--editor', '--import')
Invoke-GodotCheck 'scene-boot' @('--quit-after', '60')
Invoke-GodotCheck 'bootstrap-smoke' @('--script', 'tests/headless/bootstrap_smoke.gd')
Invoke-GodotCheck 'region-tests' @('--script', 'tests/headless/region_tests.gd')
Invoke-GodotCheck 'region-scene-smoke' @('--script', 'tests/headless/region_scene_smoke.gd')
Invoke-GodotCheck 'simulation-tests' @('--script', 'tests/headless/simulation_tests.gd')
Invoke-GodotCheck 'simulation-scene-smoke' @('--script', 'tests/headless/simulation_scene_smoke.gd')
Invoke-GodotCheck 'combat-tests' @('--script', 'tests/headless/combat_tests.gd')
Invoke-GodotCheck 'combat-scene-smoke' @('--script', 'tests/headless/combat_scene_smoke.gd')
Write-Output 'VERIFY: import, main boot, I-001/I-002/I-003 regressions and I-004 combat suites PASS'
