# Build the Android APK

Use the helper script to produce a debug APK that bundles the existing `index.html` inside a WebView wrapper.

## Prerequisites
- Java 17+ available on your PATH.
- Android SDK installed with at least one build-tools/platform version; set `ANDROID_HOME` or `ANDROID_SDK_ROOT` accordingly.
- `adb` (for optional installation to a device or emulator).

## One-command build
From the repository root:

```bash
./scripts/build-android-apk.sh
```

What the script does:
1. Copies `index.html` into `android/app/src/main/assets/`.
2. Ensures the Gradle wrapper exists (regenerates via system `gradle` if needed).
3. Runs `./gradlew assembleDebug` under `android/`.
4. Copies the resulting APK to `dist/app-debug.apk`.

## Installing the APK (optional)
After the build finishes, install the APK on a connected device or emulator:

```bash
adb install -r dist/app-debug.apk
```

If `gradle` is not installed and the wrapper JAR is missing, run the following once to generate it (then rerun the script):

```bash
(cd android && gradle wrapper --gradle-version 8.2.1)
```
