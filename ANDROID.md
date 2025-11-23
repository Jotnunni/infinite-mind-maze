# Build the Android APK (no Android Studio required)

Use the helper script to produce a debug APK that bundles the existing `index.html` inside a WebView wrapper.

> Note: This repo intentionally does not ship a prebuilt APK. Build it locally so it is signed with your environment's SDK tools. The helper script writes the result to `dist/app-debug.apk`.

### Why the APK isn't prebuilt here
- APKs must be built and signed with SDK tools on a specific machine; shipping a prebuilt binary would either be unsigned or signed with a key you don't control, which is unsafe to install.
- The helper script guarantees the APK you install comes from your own environment (and key), avoids supply-chain risk, and keeps the repo free of large binary artifacts.
- If you need to share an APK, build it once with `./scripts/build-android-apk.sh`, then distribute the resulting `dist/app-debug.apk` that you produced locally.

## Quick bootstrap (Intel/Apple Silicon macOS, no Android Studio)
Run the helper script once to install the Android command-line tools + required SDK packages under `~/Library/Android/sdk`:

```bash
chmod +x scripts/install-android-cli-macos.sh
./scripts/install-android-cli-macos.sh
```

What it does:
- Verifies Java is available (install JDK 17+ first via `brew install openjdk@17` if needed).
- Downloads the official Android command-line tools ZIP, places it under `~/Library/Android/sdk/cmdline-tools/latest/`.
- Installs `platform-tools`, `platforms;android-34`, and `build-tools;34.0.0` via `sdkmanager`.
- Prints the exports you should add to your shell profile (`ANDROID_HOME`, `ANDROID_SDK_ROOT`, and PATH entries).

If you prefer manual steps, follow the same outline above (download the CLI tools, install the three SDK packages with `sdkmanager`, and set the environment variables). Optional: `brew install android-platform-tools` if you want `adb` for installing the APK on a device/emulator.

## One-command build
From the repository root after the prerequisites:

```bash
./scripts/build-android-apk.sh
```

Quick notes on running the script:

- Make sure it is executable once (if needed): `chmod +x scripts/build-android-apk.sh`.
- Run it from the repo root so it can find `index.html` and the Android project.
- It will fail fast if Java or the Android SDK env vars (`ANDROID_HOME`/`ANDROID_SDK_ROOT`) are missing; set them first as shown above.

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

## Intel macOS one-shot script (setup + build)
If you have an older Intel MacBook without Android Studio, run this end-to-end helper from the repo root:

```bash
chmod +x scripts/mac-intel-one-shot.sh
./scripts/mac-intel-one-shot.sh
```

What it does:
- Verifies you are on Intel macOS and installs OpenJDK 17 via Homebrew if Java is missing.
- Exports the Android SDK environment variables for the current run.
- Calls `scripts/install-android-cli-macos.sh` to download the Android CLI + SDK packages.
- Calls `scripts/build-android-apk.sh` to produce `dist/app-debug.apk`.

Prereqs: Homebrew installed (`brew.sh`) and enough disk space for the SDK packages. If you already have Java and the SDK set up, the script will skip redundant installs.

## Windows 11 PowerShell helper (setup + build)
For Windows 10/11, run the PowerShell one-shot helper from the repo root. It will install the Android CLI tools via Winget (if missing), auto-accept SDK licenses, install required SDK packages, and then build.

```powershell
pwsh -ExecutionPolicy Bypass -File scripts/windows-one-shot.ps1
```

What it does:
- Verifies Java is available (expects JDK 17+; installs via `winget install EclipseAdoptium.Temurin.17.JDK` if you prefer).
- Points `ANDROID_HOME` / `ANDROID_SDK_ROOT` at `%LOCALAPPDATA%\Android\Sdk` by default.
- Installs the Android SDK command-line tools via Winget if `sdkmanager` is missing, then re-checks PATH.
- Auto-accepts SDK licenses and installs the required packages (`platform-tools`, `platforms;android-34`, `build-tools;34.0.0`).
- Syncs `index.html` into Android assets, regenerates the Gradle wrapper jar via system `gradle` if it is missing, runs `gradlew.bat assembleDebug`, and copies the APK to `dist/app-debug.apk`.

Prereqs: Windows PowerShell (or pwsh), Winget available, and either a preinstalled Android SDK or willingness to install the CLI tools via Winget. If you already have Java/SDK configured, the helper skips redundant installs.

## Installing the APK (optional)
After the build finishes, install the APK on a connected device or emulator:

```bash
adb install -r dist/app-debug.apk
```

If you only want to grab the APK (e.g., to share), it lives at `dist/app-debug.apk`.

## Creating a signed release APK
Use your own keystore to create a distributable release build. Generate one if you do not already have it:

```bash
mkdir -p ~/.keystores
keytool -genkeypair -v -keystore ~/.keystores/imm-release.keystore \
  -alias immRelease -keyalg RSA -keysize 2048 -validity 36500
```

Then export the keystore details and run the release helper from the repo root:

```bash
export IMZ_KEYSTORE_PATH=$HOME/.keystores/imm-release.keystore
export IMZ_KEY_ALIAS=immRelease
export IMZ_KEYSTORE_PASSWORD=YOUR_PASSWORD
# Optional if it differs from the keystore password:
export IMZ_KEY_PASSWORD=YOUR_KEY_PASSWORD

./scripts/build-android-release-apk.sh
```

The script will fail fast if the keystore inputs are missing or the file cannot be found. On success it writes the signed artifact to `dist/app-release.apk`.
