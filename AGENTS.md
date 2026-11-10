# Android & Kotlin CLI Development Rules

When working on Android or Kotlin projects in this workspace:
- **Headless CLI Workflow**: Do not instruct the user to click buttons in Android Studio. Perform all project scaffolding, SDK management (`sdkmanager`), builds (`.\gradlew.bat`), and device deployments (`adb`) directly via terminal commands.
- **Environment Pre-check & Cross-Machine Bootstrap**:
  - Ensure `$env:JAVA_HOME` (defaulting to `$env:LOCALAPPDATA\Programs\Temurin21`) and `$env:ANDROID_HOME` (defaulting to `$env:LOCALAPPDATA\Android\Sdk`) are active in the shell session when running Gradle or Android SDK tools.
  - On a new machine where JDK 21 or the Android SDK is not installed yet, run `powershell -ExecutionPolicy Bypass -File .\scripts\setup-android-env.ps1` to install and configure them automatically.
- **Modern Stack Defaults**: Default to Kotlin 2.x, Jetpack Compose with Material 3, Gradle Version Catalogs (`gradle/libs.versions.toml`), Kotlin DSL (`build.gradle.kts`), and `compileSdk = 35` / `minSdk = 26` unless specified otherwise.

