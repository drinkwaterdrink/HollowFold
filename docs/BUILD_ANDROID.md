# Build and test Hollowfold (I-001)

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
| APK | `builds/android/Hollowfold-debug.apk` (ignored) |

From the repository root in PowerShell:

```powershell
./tools/verify.ps1
./tools/export_android.ps1

# Open the project editor, or launch the title interface:
& '.local/tools/Godot_v4.7.2-stable_win64.exe' --path . --editor
& '.local/tools/Godot_v4.7.2-stable_win64.exe' --path .

# Optional real-renderer pointer check and screenshots:
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/visual.log" --script tests/headless/visual_smoke.gd
```

`verify.ps1` checks the exact engine version, runs headless editor import, runs the configured main scene for 60 frames, then executes the real-scene navigation/inset tests. It rejects nonzero exit codes **and** engine error messages. Logs go to `.local/verification/`. The rendered test injects pointer events through Godot's GUI and saves three viewport PNGs; it is not a physical mouse/touch or phone test.

`export_android.ps1` configures only the portable editor's SDK/JDK paths, creates a development key if missing, exports the Android preset and verifies the signature. Local JDK/SDK/output paths can be overridden with `-JdkPath`, `-AndroidSdkPath`, `-OutputPath`. Preserve the debug key to install later debug updates over the same app. Losing it can require uninstalling the old debug app (which deletes app data); do not uninstall automatically. This is not release signing.

## Install and test on a real phone

No authorized device or emulator was listed during I-001. All physical-device checks are **UNVERIFIED**. The standard template's verified minimum is API 24 (Android 7.0), target API 36; this APK contains ARM64 only. These manifest values do not establish compatibility with an untested phone.

1. Enable Developer options and USB debugging on an ARM64 Android phone. Connect a data-capable USB cable, unlock it and accept its debugging trust prompt. Install the manufacturer's Windows USB driver if ADB cannot see it.
2. From the repository root, run:

```powershell
$adb = "$PWD/.local/android-sdk/platform-tools/adb.exe"
& $adb devices -l
# Replace SERIAL with the authorized device's serial. Do not use an unauthorized entry.
& $adb -s SERIAL install -r "$PWD/builds/android/Hollowfold-debug.apk"
& $adb -s SERIAL shell am start -n io.github.drinkwaterdrink.hollowfold/com.godot.game.GodotAppLauncher
# Capture logs and a screenshot after exercising the controls:
& $adb -s SERIAL logcat -d -s godot AndroidRuntime > .local/verification/device-log.txt
& $adb -s SERIAL shell screencap -p /sdcard/hollowfold-i001.png
& $adb -s SERIAL pull /sdcard/hollowfold-i001.png .local/verification/device-portrait.png
```

3. Verify first boot shows **Hollowfold**, New Run and Settings, with no Continue. Tap New Run → read the placeholder → Back. Tap Settings → Back. Repeat quickly; test system Back from both child panels. System Back at the title retains the title in this bootstrap. Verify portrait remains locked when rotating the phone.
4. Inspect every screen with gesture navigation and cutouts: no text/button overlaps system bars or camera holes; Back remains reachable, scrolling works on a small screen, text and touch targets feel comfortable. Repeat with larger system font/display settings; inherited system text scaling is not claimed to be implemented in I-001.
5. Background/resume each panel, lock/unlock, then force-stop/relaunch; this bootstrap starts at the title and has no saved run. Use airplane mode to confirm every available interaction works offline. Observe for errors/crashes over repeated navigation; no gameplay exists to test yet.
6. Save phone model, Android version, install/launch output, observations and screenshot in the progress evidence before approving I-002.

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
