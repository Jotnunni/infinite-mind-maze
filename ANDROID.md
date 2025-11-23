# Build the Android APK (no Android Studio required)

Use the helper script to produce a debug APK that bundles the existing `index.html` inside a WebView wrapper.

## Prerequisites (Intel macOS without Android Studio)
1) Install Java 17+: `brew install openjdk@17` (or any JDK 17+).
2) Install the Android command-line tools only:
   - Download the macOS ZIP from <https://developer.android.com/studio#command-line-tools-only>.
   - Unzip and place `cmdline-tools` under `~/Library/Android/sdk/` so you end up with `~/Library/Android/sdk/cmdline-tools/latest`.
3) Export environment variables (add to your shell profile):
   ```bash
   export ANDROID_HOME="$HOME/Library/Android/sdk"
   export ANDROID_SDK_ROOT="$ANDROID_HOME"
   export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
   export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
   ```
4) Install the needed platforms/build-tools with `sdkmanager` (run from any shell):
   ```bash
   sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```
5) Optional: `brew install android-platform-tools` if you want `adb` for installing the APK on a device/emulator.

## One-command build
From the repository root after the prerequisites:

```bash
./scripts/build-android-apk.sh
```

What the script does:
1. Copies `index.html` into `android/app/src/main/assets/`.
2. Ensures the Gradle wrapper exists (regenerates via system `gradle` if needed).
3. Runs `./gradlew assembleDebug` under `android/`.
4. Copies the resulting APK to `dist/app-debug.apk`.

If the script reports a missing Gradle wrapper and you have `gradle` installed, generate it once:
```bash
(cd android && gradle wrapper --gradle-version 8.2.1)
```
Then re-run the build script.

## Installing the APK (optional)
After the build finishes, install the APK on a connected device or emulator:

```bash
adb install -r dist/app-debug.apk
```

If you only want to grab the APK (e.g., to share), it lives at `dist/app-debug.apk`.
