#!/usr/bin/env bash
set -euo pipefail

# Build a signed release APK for Infinite Mind Maze.
# Requires a user-provided keystore via environment variables:
#   IMZ_KEYSTORE_PATH     - path to the keystore file
#   IMZ_KEY_ALIAS         - key alias inside the keystore
#   IMZ_KEYSTORE_PASSWORD - keystore password
#   IMZ_KEY_PASSWORD      - key password (defaults to IMZ_KEYSTORE_PASSWORD when unset)
# The script fails fast if the keystore inputs are missing to avoid producing an unsigned APK.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$REPO_ROOT/android"
ASSETS_DIR="$ANDROID_DIR/app/src/main/assets"
APK_OUT="$ANDROID_DIR/app/build/outputs/apk/release/app-release.apk"
DIST_DIR="$REPO_ROOT/dist"
WRAPPER_JAR="$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar"

log() { printf "[build-release] %s\n" "$*"; }

check_env() {
  if ! command -v java >/dev/null 2>&1; then
    log "Java is missing. Install JDK 17+ (e.g., brew install openjdk@17) and retry."
    exit 1
  fi

  if [[ -z "${ANDROID_HOME:-}" && -z "${ANDROID_SDK_ROOT:-}" ]]; then
    log "ANDROID_HOME / ANDROID_SDK_ROOT not set. Set them to your Android SDK path before running."
    exit 1
  fi

  if [[ -z "${IMZ_KEYSTORE_PATH:-}" || -z "${IMZ_KEY_ALIAS:-}" || -z "${IMZ_KEYSTORE_PASSWORD:-}" ]]; then
    log "Keystore details missing. Set IMZ_KEYSTORE_PATH, IMZ_KEY_ALIAS, and IMZ_KEYSTORE_PASSWORD (IMZ_KEY_PASSWORD optional)."
    log "Example: IMZ_KEYSTORE_PATH=$HOME/.keystores/imm-release.keystore IMZ_KEY_ALIAS=immRelease IMZ_KEYSTORE_PASSWORD=secret ./scripts/build-android-release-apk.sh"
    exit 1
  fi

  if [[ ! -f "$IMZ_KEYSTORE_PATH" ]]; then
    log "Keystore not found at $IMZ_KEYSTORE_PATH"
    exit 1
  fi
}

action_sync_assets() {
  log "Syncing HTML bundle into Android assets..."
  mkdir -p "$ASSETS_DIR"
  cp "$REPO_ROOT/index.html" "$ASSETS_DIR/index.html"
}

action_ensure_wrapper() {
  if [[ -f "$WRAPPER_JAR" ]]; then
    return
  fi

  if command -v gradle >/dev/null 2>&1; then
    log "Gradle wrapper jar missing; regenerating via system gradle..."
    (cd "$ANDROID_DIR" && gradle wrapper --gradle-version 8.2.1)
  else
    log "Gradle wrapper jar missing and no system gradle found."
    log "Install Gradle locally and run: (cd android && gradle wrapper --gradle-version 8.2.1)"
    exit 1
  fi
}

action_build_apk() {
  log "Building release APK with signing credentials from environment..."
  (cd "$ANDROID_DIR" && ./gradlew assembleRelease)
}

action_collect_artifact() {
  if [[ -f "$APK_OUT" ]]; then
    mkdir -p "$DIST_DIR"
    cp "$APK_OUT" "$DIST_DIR/app-release.apk"
    log "APK ready: $DIST_DIR/app-release.apk"
  else
    log "Build finished but APK not found at $APK_OUT" >&2
    exit 1
  fi
}

check_env
action_sync_assets
action_ensure_wrapper
action_build_apk
action_collect_artifact
