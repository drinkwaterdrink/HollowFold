# Build and test Hollowfold

Use **Godot 4.7.2 stable**, GDScript and Compatibility. The repository is `HollowFold`; the app is **Hollowfold**, ID `io.github.drinkwaterdrink.hollowfold`.

## This computer is prepared

The following portable tools were installed under this checkout's ignored `.local/` directory. Nothing was added to system PATH or the user's global Godot settings.

| Tool | Local path / version |
|---|---|
| Godot | `.local/tools/Godot_v4.7.2-stable_win64_console.exe`, `4.7.2.stable.official.ed1daf0bf` |
| Portable editor mode | `.local/tools/_sc_`; settings in `.local/tools/editor_data/` |
| Templates | `.local/tools/editor_data/export_templates/4.7.2.stable/android_debug.apk` and `android_release.apk` |
| JDK | `.local/tools/jdk/jdk-17.0.20.1+1` (OpenJDK 17) |
| Android SDK | `.local/android-sdk`, platform-tools, build-tools 36.0.0 and platform android-36 (35 tools also installed during initial investigation) |
| Development key | `.local/debug.keystore`, generated locally; never upload/commit |
| Current APK | `builds/android/Hollowfold-I004-debug.apk` (ignored); previous I-001/I-002/I-003 APKs preserved |

From the repository root in PowerShell:

```powershell
./tools/verify.ps1
./tools/export_android.ps1

# Open the project editor, or launch the title interface:
& '.local/tools/Godot_v4.7.2-stable_win64.exe' --path . --editor
& '.local/tools/Godot_v4.7.2-stable_win64.exe' --path .

# Optional real-renderer pointer check and screenshots:
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/visual.log" --script tests/headless/visual_smoke.gd
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/region-visual.log" --script tests/headless/region_visual_smoke.gd
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/i003-visual.log" --script tests/headless/simulation_visual_smoke.gd
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/i004-visual.log" --script tests/headless/combat_visual_smoke.gd
```

`verify.ps1` checks the exact engine version, runs headless editor import, runs the configured main scene for 60 frames, then executes I-001 regressions, I-002 terrain/scene regressions I-003 simulation/scene tests and I-004 combat/replay/AI/scene tests. It rejects nonzero exit codes **and** engine error messages. Logs go to `.local/verification/`. Rendered tests inject pointer/key/touch events through Godot's viewport and save PNGs; they are not physical phone tests or certification of Android's OS touch-to-mouse adapter.

`export_android.ps1` configures only the portable editor's SDK/JDK paths, creates a development key if missing, exports the Android preset and verifies the signature. Local JDK/SDK/output paths can be overridden with `-JdkPath`, `-AndroidSdkPath`, `-OutputPath`. Preserve the debug key to install later debug updates over the same app. Losing it can require uninstalling the old debug app (which deletes app data); do not uninstall automatically. This is not release signing.

## Install and test on a real phone

I-001 through I-003 were accepted following user-reported physical passes. No authorized device or emulator is listed for agent-run I-004 checks, so **I-004 physical-device testing is UNVERIFIED**. The template's verified minimum is API 24 (Android 7.0), target API 36; this APK contains ARM64 only. Prior acceptance does not establish behavior of the changed I-004 APK.

1. Enable Developer options and USB debugging on an ARM64 Android phone. Connect a data-capable USB cable, unlock it and accept its debugging trust prompt. Install the manufacturer's Windows USB driver if ADB cannot see it.
2. From the repository root, run:

```powershell
$adb = "$PWD/.local/android-sdk/platform-tools/adb.exe"
& $adb devices -l
# Replace SERIAL with the authorized device's serial. Do not use an unauthorized entry.
& $adb -s SERIAL install -r "$PWD/builds/android/Hollowfold-I004-debug.apk"
& $adb -s SERIAL shell am start -n io.github.drinkwaterdrink.hollowfold/com.godot.game.GodotAppLauncher
# Capture logs and a screenshot after exercising the controls:
& $adb -s SERIAL logcat -d -s godot AndroidRuntime > .local/verification/device-log.txt
& $adb -s SERIAL shell screencap -p /sdcard/hollowfold-i004.png
& $adb -s SERIAL pull /sdcard/hollowfold-i004.png .local/verification/device-portrait-i004.png
```

3. Follow the exact I-004 checklist in [I-004_Verification.md](I-004_Verification.md). Explore, inspect/select the mite, Attack, check hit/miss/damage, HP/stamina, stamina recovery, pursuit/retreat, defeat and regeneration. Rejections and Inspect must not advance time or enemy turns. Rapid/overlapping touches must not duplicate attacks.
4. Check small portrait screens, cutouts, gesture navigation, Back, background/resume and offline operation. Idle/menu time must not advance combat. Force-stop/relaunch returns to title without a saved run.
5. Record phone model, Android version and PASS/FAIL results before approving I-004. **Do not begin I-005 without explicit approval.** No additional toolchain setup is needed on this computer; only phone connection/install/manual checks remain.

## Recreate the toolchain on another Windows machine

The `.local/` tools are intentionally not in Git. Obtain official distributions:

- [Godot 4.7.2 archive](https://godotengine.org/download/archive/4.7.2-stable/): Windows 64-bit standard editor and matching export templates. Extract editor executables to `.local/tools/`, create an empty `_sc_` file beside them, and put `android_debug.apk`, `android_release.apk`, `version.txt` from the template archive's `templates/` folder in `editor_data/export_templates/4.7.2.stable/`.
- [Temurin OpenJDK 17](https://adoptium.net/temurin/releases/?version=17): extract the Windows x64 JDK ZIP under `.local/tools/jdk/`.
- [Android command-line tools](https://developer.android.com/studio#command-tools): extract under `.local/tools/android-cli/`, set this process's `JAVA_HOME` to the extracted JDK and run:

```powershell
$env:JAVA_HOME = (Get-ChildItem .local/tools/jdk -Directory | Select-Object -First 1).FullName
$sdkRoot = "$PWD/.local/android-sdk"
& '.local/tools/android-cli/cmdline-tools/bin/sdkmanager.bat' "--sdk_root=$sdkRoot" --licenses
& '.local/tools/android-cli/cmdline-tools/bin/sdkmanager.bat' "--sdk_root=$sdkRoot" 'platform-tools' 'build-tools;36.0.0' 'platforms;android-36'
./tools/verify.ps1
./tools/export_android.ps1
```

The [stable Godot Android guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) recommends JDK 17 and listed SDK 35 packages at implementation time. The actual pinned 4.7.2 template reports target SDK 36, so this project uses matching API 36 tools. The standard prebuilt APK export succeeded without NDK, CMake or Gradle. Install those only if a later packet demonstrably needs custom/native builds. No manual tool setup remains necessary on this computer for the successful debug export; only device connection and manual acceptance remain.
