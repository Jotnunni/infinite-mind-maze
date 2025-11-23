#!/usr/bin/env bash
set -euo pipefail

# End-to-end helper for Intel macOS: installs Android CLI deps (via the existing
# installer script) and builds the debug APK. Designed for older Intel MacBooks
# without Android Studio.

log() { echo "[mac-intel-one-shot] $*"; }
err() { echo "[mac-intel-one-shot] $*" >&2; }

if [[ "$(uname)" != "Darwin" ]]; then
  err "This script is intended for macOS."; exit 1; fi

if [[ "$(uname -m)" != "x86_64" ]]; then
  err "This helper targets Intel Macs (x86_64). For Apple Silicon, use the existing scripts directly."; exit 1; fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SCRIPT="$REPO_ROOT/scripts/install-android-cli-macos.sh"
BUILD_SCRIPT="$REPO_ROOT/scripts/build-android-apk.sh"

if [[ ! -x "$INSTALL_SCRIPT" ]]; then chmod +x "$INSTALL_SCRIPT"; fi
if [[ ! -x "$BUILD_SCRIPT" ]]; then chmod +x "$BUILD_SCRIPT"; fi

require_homebrew() {
  if command -v brew >/dev/null 2>&1; then return; fi
  err "Homebrew not found. Install it first from https://brew.sh, then re-run this script."; exit 1;
}

install_java_if_missing() {
  if command -v java >/dev/null 2>&1; then return; fi
  require_homebrew
  log "Installing OpenJDK 17 via Homebrew..."
  brew install openjdk@17
}

set_java_home() {
  if [[ -n "${JAVA_HOME:-}" ]]; then
    export JAVA_HOME
  else
    if command -v /usr/libexec/java_home >/dev/null 2>&1; then
      local candidate
      candidate="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"
      if [[ -n "$candidate" ]]; then
        export JAVA_HOME="$candidate"
      fi
    fi
    if [[ -z "${JAVA_HOME:-}" && -d "/usr/local/opt/openjdk@17" ]]; then
      export JAVA_HOME="/usr/local/opt/openjdk@17"
    fi
  fi

  if [[ -n "${JAVA_HOME:-}" && -d "$JAVA_HOME/bin" ]]; then
    export PATH="$JAVA_HOME/bin:$PATH"
  fi
}

prepare_android_env() {
  export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-"$HOME/Library/Android/sdk"}}"
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
  local cli_bin="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
  local plat_bin="$ANDROID_SDK_ROOT/platform-tools"
  export PATH="$cli_bin:$plat_bin:$PATH"
}

log "Ensuring Java and Android command-line tools..."
install_java_if_missing
set_java_home
prepare_android_env

log "Running CLI installer (may download SDK packages)..."
"$INSTALL_SCRIPT"

log "Building debug APK..."
"$BUILD_SCRIPT"

log "Done. The APK should now be at $REPO_ROOT/dist/app-debug.apk"
