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
| Current APK | `builds/android/Hollowfold-I002-debug.apk` (ignored); previous I-001 APK preserved as `Hollowfold-debug.apk` |

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
```

`verify.ps1` checks the exact engine version, runs headless editor import, runs the configured main scene for 60 frames, then executes the original I-001 navigation/inset tests plus I-002 pure generation/collision and integrated scene tests. It rejects nonzero exit codes **and** engine error messages. Logs go to `.local/verification/`. Rendered tests inject pointer/key events through Godot's GUI and save viewport PNGs; they are not physical mouse/touch or phone tests.

`export_android.ps1` configures only the portable editor's SDK/JDK paths, creates a development key if missing, exports the Android preset and verifies the signature. Local JDK/SDK/output paths can be overridden with `-JdkPath`, `-AndroidSdkPath`, `-OutputPath`. Preserve the debug key to install later debug updates over the same app. Losing it can require uninstalling the old debug app (which deletes app data); do not uninstall automatically. This is not release signing.

## Install and test on a real phone

I-001 was accepted following the user's nine reported physical passes. No authorized device or emulator is currently listed for agent-run I-002 checks, so **I-002 physical-device testing is UNVERIFIED**. The standard template's verified minimum is API 24 (Android 7.0), target API 36; this APK contains ARM64 only. These manifest values do not establish compatibility with an untested phone.

1. Enable Developer options and USB debugging on an ARM64 Android phone. Connect a data-capable USB cable, unlock it and accept its debugging trust prompt. Install the manufacturer's Windows USB driver if ADB cannot see it.
2. From the repository root, run:

```powershell
$adb = "$PWD/.local/android-sdk/platform-tools/adb.exe"
& $adb devices -l
# Replace SERIAL with the authorized device's serial. Do not use an unauthorized entry.
& $adb -s SERIAL install -r "$PWD/builds/android/Hollowfold-I002-debug.apk"
& $adb -s SERIAL shell am start -n io.github.drinkwaterdrink.hollowfold/com.godot.game.GodotAppLauncher
# Capture logs and a screenshot after exercising the controls:
& $adb -s SERIAL logcat -d -s godot AndroidRuntime > .local/verification/device-log.txt
& $adb -s SERIAL shell screencap -p /sdcard/hollowfold-i002.png
& $adb -s SERIAL pull /sdcard/hollowfold-i002.png .local/verification/device-portrait-i002.png
```

3. Verify first boot shows **Hollowfold**, New Run and Settings, with no Continue. Tap New Run → Explore region. Walk for at least five minutes using the pad; verify rock/water/bounds reject movement, the camera follows and the gold entrance is visible. Regenerate returns to the same seed/map/spawn; Next seed changes the map. Back returns to New Run and then title. Verify Settings, system Back and portrait rotation lock still work.
4. Inspect every screen with gesture navigation and cutouts: no text/button overlaps system bars or camera holes; Back remains reachable, scrolling works on a small screen, text and touch targets feel comfortable. Repeat with larger system font/display settings; inherited system text scaling is not claimed to be implemented in I-001.
5. Background/resume during exploration, then force-stop/relaunch. Returning without process death should retain temporary in-memory exploration; process restart starts at title and has no saved run. Use airplane mode to confirm movement/regeneration/navigation work offline. No scheduler, combat or saves exist yet.
6. Save phone model, Android version, install/launch output, observations and screenshot in the progress evidence before approving I-002 and authorizing I-003. The detailed packet checklist is in `docs/I-002_Verification.md`.

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
