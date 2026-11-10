---
name: android-kotlin-dev
description: CLI-first Android and Kotlin development skill for building, testing, and debugging Jetpack Compose Android apps directly in Antigravity without Android Studio. Use whenever scaffolding an Android project, writing Kotlin/Jetpack Compose UI, managing Gradle dependencies, running sdkmanager/avdmanager/adb commands, or building APKs.
---

# Android & Kotlin CLI Development Skill

Use this skill when creating, building, testing, or debugging Android applications in Kotlin from Antigravity using command-line tools.

## 1. Environment & Toolchain Locations (Cross-Machine Portable)

- **Bootstrap Script**: `scripts/setup-android-env.ps1`
  - If `java` or `adb` / `sdkmanager` are missing on a new machine, run:
    ```powershell
    powershell -ExecutionPolicy Bypass -File .\scripts\setup-android-env.ps1
    ```
- **JDK 21 (`JAVA_HOME`)**: `$env:LOCALAPPDATA\Programs\Temurin21` (if not already set in `$env:JAVA_HOME`)
- **Android SDK (`ANDROID_HOME` / `ANDROID_SDK_ROOT`)**: `$env:LOCALAPPDATA\Android\Sdk` (if not already set in `$env:ANDROID_HOME`)
- **Key CLI Binaries**:
  - `sdkmanager.bat` / `avdmanager.bat`: `$env:ANDROID_HOME\cmdline-tools\latest\bin`
  - `adb.exe`: `$env:ANDROID_HOME\platform-tools\adb.exe`
  - `emulator.exe`: `$env:ANDROID_HOME\emulator\emulator.exe`

Always verify `JAVA_HOME` and `ANDROID_HOME` are active in the current PowerShell session before running Gradle or `sdkmanager`:
```powershell
if (-not $env:JAVA_HOME -or -not (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
    $env:JAVA_HOME = "$env:LOCALAPPDATA\Programs\Temurin21"
}
if (-not $env:ANDROID_HOME -or -not (Test-Path $env:ANDROID_HOME)) {
    $env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
    $env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
}
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:ANDROID_HOME\emulator;$env:Path"
```

## 2. Scaffolding a Headless Android Project (No Android Studio Needed)

When creating a new Android project from scratch:
1. **Gradle Wrapper**: Generate or include `gradlew.bat`, `gradlew`, and `gradle/wrapper/gradle-wrapper.properties` (targeting Gradle 8.9+ compatible with AGP 8.7+).
2. **Version Catalog (`gradle/libs.versions.toml`)**: Centralize all versions and libraries:
   - Kotlin `2.0.21+` with `org.jetbrains.kotlin.plugin.compose`
   - Android Gradle Plugin (AGP) `8.7.2+`
   - Jetpack Compose BOM (`androidx.compose:compose-bom:2024.10.01+`)
   - Material 3 (`androidx.compose.material3:material3`)
   - Activity Compose (`androidx.activity:activity-compose`)
   - Lifecycle ViewModel Compose (`androidx.lifecycle:lifecycle-viewmodel-compose`)
3. **`local.properties`**: Always keep `local.properties` in `.gitignore` since SDK paths vary per machine. Gradle automatically reads `ANDROID_HOME` when `local.properties` is absent, or you can generate it dynamically from `$env:ANDROID_HOME`.

## 3. Essential CLI Workflows

### Managing SDK Packages (`sdkmanager`)
```powershell
# Accept all SDK licenses non-interactively
1..15 | ForEach-Object { "y" } | sdkmanager --licenses

# Install platform-tools, build-tools, and Android 35 (API 35) platform
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"
```

### Building & Testing via Gradle Wrapper (`.\gradlew.bat`)
```powershell
# Assemble Debug APK
.\gradlew.bat assembleDebug --stacktrace

# Run Unit Tests
.\gradlew.bat testDebugUnitTest

# Run Lint Checks
.\gradlew.bat lintDebug
```
Output APK path: `app\build\outputs\apk\debug\app-debug.apk`

### Device & Emulator Deployment (`adb` & `avdmanager`)
```powershell
# List connected devices/emulators
adb devices -l

# Install and launch debug APK on connected device/emulator
adb install -r app\build\outputs\apk\debug\app-debug.apk
adb shell am start -n <package_name>/.MainActivity

# Stream crash and app logs
adb logcat -v color *:E AndroidRuntime:E
```

## 4. Kotlin & Jetpack Compose Best Practices

- **Unidirectional Data Flow (UDF)**: Expose immutable `StateFlow<UiState>` from `ViewModel` and collect with `collectAsStateWithLifecycle()` in Compose.
- **Stateless Composables**: Hoist state out of screen/component composables so they accept state values and event lambdas (`onAction: () -> Unit`).
- **Material 3**: Use `MaterialTheme`, dynamic color support (with fallback schemes), and `Scaffold` with proper edge-to-edge (`enableEdgeToEdge()`) window insets handling.
- **Coroutines & Structured Concurrency**: Use `viewModelScope` for UI-triggered async work and inject `CoroutineDispatcher`s rather than hardcoding `Dispatchers.IO`.

