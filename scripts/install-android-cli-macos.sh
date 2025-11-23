#!/usr/bin/env bash
set -euo pipefail

# Bootstrap Android command-line tools on macOS (Intel/Apple Silicon) without Android Studio.
# This installs the command-line tools, platform-tools, Android 34 platform, and build-tools 34.0.0
# under ~/Library/Android/sdk and prints the environment exports needed for builds.

if [[ "$(uname)" != "Darwin" ]]; then
  echo "[install-android-cli] This script is intended for macOS." >&2
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "[install-android-cli] Missing 'unzip'. Install via: brew install unzip" >&2
  exit 1
fi

SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-"$HOME/Library/Android/sdk"}}"
CMDLINE_DIR="$SDK_ROOT/cmdline-tools/latest"
SDKMANAGER="$CMDLINE_DIR/bin/sdkmanager"

mkdir -p "$SDK_ROOT"

download_cli_tools() {
  local url="https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip"
  local zip="$SDK_ROOT/commandlinetools.zip"
  echo "[install-android-cli] Downloading Android command-line tools..."
  curl -L "$url" -o "$zip"
  rm -rf "$SDK_ROOT/cmdline-tools"
  mkdir -p "$SDK_ROOT/cmdline-tools"
  unzip -q "$zip" -d "$SDK_ROOT/cmdline-tools"
  mv "$SDK_ROOT/cmdline-tools/cmdline-tools" "$CMDLINE_DIR"
  rm -f "$zip"
}

ensure_cli_tools() {
  if [[ -x "$SDKMANAGER" ]]; then
    return
  fi
  download_cli_tools
}

install_sdk_packages() {
  echo "[install-android-cli] Installing platform-tools, platform android-34, and build-tools 34.0.0..."
  yes | "$SDKMANAGER" --sdk_root="$SDK_ROOT" "platform-tools" "platforms;android-34" "build-tools;34.0.0"
}

print_exports() {
  cat <<EON
[install-android-cli] Done. Add these lines to your shell profile (~/.zshrc or ~/.bashrc):
  export ANDROID_HOME="$SDK_ROOT"
  export ANDROID_SDK_ROOT="$SDK_ROOT"
  export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$SDK_ROOT/platform-tools:$SDK_ROOT/emulator:\$PATH"
EON
}

check_java() {
  if command -v java >/dev/null 2>&1; then
    return
  fi
  echo "[install-android-cli] Java (JDK 17+) not found. Install it first, e.g.: brew install openjdk@17" >&2
  exit 1
}

check_java
ensure_cli_tools
install_sdk_packages
print_exports

echo "[install-android-cli] Android CLI setup complete. Run ./scripts/build-android-apk.sh from the repo root next."
