[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info([string]$Message) { Write-Host "[windows-one-shot] $Message" }
function Write-Err([string]$Message)  { Write-Host "[windows-one-shot] $Message" -ForegroundColor Red }

if (-not $IsWindows) {
  Write-Err 'This helper is intended for Windows 10/11 PowerShell.'
  exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = (Resolve-Path (Join-Path $ScriptDir '..')).Path
$AndroidDir = Join-Path $RepoRoot 'android'
$AssetsDir  = Join-Path $AndroidDir 'app/src/main/assets'
$ApkOut     = Join-Path $AndroidDir 'app/build/outputs/apk/debug/app-debug.apk'
$DistDir    = Join-Path $RepoRoot 'dist'
$WrapperJar = Join-Path $AndroidDir 'gradle/wrapper/gradle-wrapper.jar'
$GradlewBat = Join-Path $AndroidDir 'gradlew.bat'

function Ensure-Java {
  if (Get-Command java -ErrorAction SilentlyContinue) { return }
  Write-Err 'Java (JDK 17+) is required. Install via winget: winget install EclipseAdoptium.Temurin.17.JDK'
  exit 1
}

function Prepare-AndroidEnv {
  if (-not $env:ANDROID_SDK_ROOT -and -not $env:ANDROID_HOME) {
    $defaultSdk = Join-Path $env:LOCALAPPDATA 'Android/Sdk'
    $env:ANDROID_SDK_ROOT = $defaultSdk
    $env:ANDROID_HOME = $defaultSdk
  } elseif (-not $env:ANDROID_SDK_ROOT) {
    $env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
  } elseif (-not $env:ANDROID_HOME) {
    $env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
  }

  $cliBin  = Join-Path $env:ANDROID_SDK_ROOT 'cmdline-tools/latest/bin'
  $platBin = Join-Path $env:ANDROID_SDK_ROOT 'platform-tools'

  $paths = @($cliBin, $platBin) | Where-Object { Test-Path $_ }
  if ($paths.Count -gt 0) {
    $env:PATH = ($paths -join ';') + ';' + $env:PATH
  }
}

function Ensure-SdkManager {
  if (Get-Command sdkmanager -ErrorAction SilentlyContinue) { return }
  Write-Err 'Android SDK command-line tools not found. Install them first (PowerShell): winget install Google.AndroidSDK.CommandlineTools'
  Write-Err 'After install, set ANDROID_SDK_ROOT/ANDROID_HOME and re-run this script.'
  exit 1
}

function Sync-Assets {
  Write-Info 'Syncing index.html into Android assets...'
  New-Item -ItemType Directory -Force -Path $AssetsDir | Out-Null
  Copy-Item -Path (Join-Path $RepoRoot 'index.html') -Destination (Join-Path $AssetsDir 'index.html') -Force
}

function Ensure-Wrapper {
  if (Test-Path $WrapperJar) { return }
  if (Get-Command gradle -ErrorAction SilentlyContinue) {
    Write-Info 'Gradle wrapper jar missing; regenerating via system gradle...'
    Push-Location $AndroidDir
    gradle wrapper --gradle-version 8.2.1
    Pop-Location
  } else {
    Write-Err 'Gradle wrapper jar missing and no system gradle found.'
    Write-Err 'Install Gradle and run: (cd android && gradle wrapper --gradle-version 8.2.1)'
    exit 1
  }
}

function Build-Apk {
  Write-Info 'Building debug APK via Gradle wrapper...'
  Push-Location $AndroidDir
  & $GradlewBat assembleDebug
  Pop-Location
}

function Collect-Artifact {
  if (-not (Test-Path $ApkOut)) {
    Write-Err "Build finished but APK not found at $ApkOut"
    return
  }
  New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
  Copy-Item -Path $ApkOut -Destination (Join-Path $DistDir 'app-debug.apk') -Force
  Write-Info "APK ready: $(Join-Path $DistDir 'app-debug.apk')"
}

Ensure-Java
Prepare-AndroidEnv
Ensure-SdkManager
Sync-Assets
Ensure-Wrapper
Build-Apk
Collect-Artifact
Write-Info 'Done.'
