param(
    [string]$AndroidSdkPath = "$PSScriptRoot/../.local/android-sdk",
    [string]$JdkPath = '',
    [string]$OutputPath = "$PSScriptRoot/../builds/android/Hollowfold-debug.apk"
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$toolRoot = Join-Path $repoRoot '.local/tools'
$godot = Join-Path $toolRoot 'Godot_v4.7.2-stable_win64_console.exe'
if (!$JdkPath) { $JdkPath = (Get-ChildItem "$toolRoot/jdk" -Directory | Select-Object -First 1).FullName }
$sdk = (Resolve-Path -LiteralPath $AndroidSdkPath).Path.Replace('\', '/')
$jdk = (Resolve-Path -LiteralPath $JdkPath).Path.Replace('\', '/')
foreach ($file in @($godot, "$jdk/bin/keytool.exe", "$sdk/build-tools/36.0.0/apksigner.bat", "$toolRoot/editor_data/export_templates/4.7.2.stable/android_debug.apk", "$toolRoot/_sc_")) {
    if (!(Test-Path -LiteralPath $file)) { throw "Missing tool: $file. See docs/BUILD_ANDROID.md." }
}
$version = & $godot --version
if ($LASTEXITCODE -ne 0 -or $version -notmatch '^4\.7\.2\.stable\.') { throw "Wrong Godot version: $version" }
# Only the isolated portable editor's settings are changed, never the user's global settings.
$settingsPath = Join-Path $toolRoot 'editor_data/editor_settings-4.7.tres'
if (Test-Path -LiteralPath $settingsPath) { $settings = Get-Content -LiteralPath $settingsPath -Raw }
else { $settings = "[gd_resource type=`"EditorSettings`" format=3]`n`n[resource]`n" }
foreach ($entry in @(@('export/android/java_sdk_path', $jdk), @('export/android/android_sdk_path', $sdk))) {
    $pattern = '(?m)^' + [regex]::Escape($entry[0]) + ' = ".*"\r?$'
    $replacement = $entry[0] + ' = "' + $entry[1] + '"'
    if ($settings -match $pattern) { $settings = [regex]::Replace($settings, $pattern, $replacement) }
    else { $settings += "`n$replacement`n" }
}
Set-Content -LiteralPath $settingsPath -Value $settings -Encoding utf8
$env:JAVA_HOME = $jdk
$env:GODOT_ANDROID_KEYSTORE_DEBUG_PATH = Join-Path $repoRoot '.local/debug.keystore'
$env:GODOT_ANDROID_KEYSTORE_DEBUG_USER = 'androiddebugkey'
$env:GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD = 'android'
if (!(Test-Path -LiteralPath $env:GODOT_ANDROID_KEYSTORE_DEBUG_PATH)) {
    & "$jdk/bin/keytool.exe" -genkeypair -keystore $env:GODOT_ANDROID_KEYSTORE_DEBUG_PATH -storepass android -alias androiddebugkey -keypass android -dname 'CN=Android Debug,O=Android,C=US' -keyalg RSA -keysize 2048 -validity 10000
    if ($LASTEXITCODE -ne 0) { throw 'Debug key generation failed' }
}
$output = [IO.Path]::GetFullPath($OutputPath)
New-Item -ItemType Directory -Force (Split-Path $output -Parent) | Out-Null
$logPath = Join-Path $repoRoot '.local/android-export.log'
& $godot --headless --path $repoRoot --log-file $logPath --export-debug Android $output 2>&1 | Tee-Object -FilePath "$logPath.console.txt"
if ($LASTEXITCODE -ne 0) { throw "Export failed with exit code $LASTEXITCODE" }
if (Select-String -LiteralPath "$logPath.console.txt" -Pattern '(^|\s)(SCRIPT ERROR:|ERROR:|Parse Error:)' -Quiet) { throw 'Export emitted errors' }
& "$sdk/build-tools/36.0.0/apksigner.bat" verify --verbose $output
if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed' }
Get-Item -LiteralPath $output | Select-Object FullName, Length
Get-FileHash -LiteralPath $output -Algorithm SHA256
