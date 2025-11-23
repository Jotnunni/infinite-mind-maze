#!/usr/bin/env bash
set -euo pipefail

# Build a debug APK for Infinite Mind Maze using the Android WebView wrapper.
# Steps performed:
# 1. Sync root index.html into android/app/src/main/assets/
# 2. Ensure the Gradle wrapper jar exists (optionally regenerates via system gradle)
# 3. Run ./gradlew assembleDebug inside the android project
# 4. Copy the built APK to ./dist/app-debug.apk for convenience

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$REPO_ROOT/android"
ASSETS_DIR="$ANDROID_DIR/app/src/main/assets"
APK_OUT="$ANDROID_DIR/app/build/outputs/apk/debug/app-debug.apk"
DIST_DIR="$REPO_ROOT/dist"
WRAPPER_JAR="$ANDROID_DIR/gradle/wrapper/gradle-wrapper.jar"

log() { printf "[build-apk] %s\n" "$*"; }

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
  log "Building debug APK..."
  (cd "$ANDROID_DIR" && ./gradlew assembleDebug)
}

action_collect_artifact() {
  if [[ -f "$APK_OUT" ]]; then
    mkdir -p "$DIST_DIR"
    cp "$APK_OUT" "$DIST_DIR/app-debug.apk"
    log "APK ready: $DIST_DIR/app-debug.apk"
  else
    log "Build finished but APK not found at $APK_OUT" >&2
  fi
}

action_sync_assets
action_ensure_wrapper
action_build_apk
action_collect_artifact
