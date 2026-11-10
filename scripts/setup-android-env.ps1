<#
.SYNOPSIS
    Bootstraps the headless Android & Kotlin CLI development environment on Windows.
    Installs Portable Eclipse Temurin JDK 21, Android SDK Command-Line Tools,
    Platform-Tools (ADB), Build-Tools 35.0.0, and Android 35 Platform SDK,
    and configures User environment variables (JAVA_HOME, ANDROID_HOME, ANDROID_SDK_ROOT, Path).
#>

$ErrorActionPreference = "Stop"

$jdkDir = "$env:LOCALAPPDATA\Programs\Temurin21"
$sdkDir = "$env:LOCALAPPDATA\Android\Sdk"
$latestCmdlineDir = "$sdkDir\cmdline-tools\latest"

Write-Host "=== 1. Checking Eclipse Temurin JDK 21 ==="
if (-not (Test-Path "$jdkDir\bin\java.exe")) {
    New-Item -ItemType Directory -Force -Path $jdkDir | Out-Null
    $zipPath = "$env:TEMP\temurin21.zip"
    Write-Host "Downloading Temurin JDK 21..."
    curl.exe -sSL "https://api.adoptium.net/v3/binary/latest/21/ga/windows/x64/jdk/hotspot/normal/eclipse" -o $zipPath
    Write-Host "Extracting JDK 21 to $jdkDir..."
    Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\temurin21_extract" -Force
    $inner = Get-ChildItem "$env:TEMP\temurin21_extract" | Select-Object -First 1
    Copy-Item -Path "$($inner.FullName)\*" -Destination $jdkDir -Recurse -Force
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\temurin21_extract" -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Temurin JDK 21 already installed at $jdkDir"
}

Write-Host "`n=== 2. Checking Android SDK Command-Line Tools ==="
if (-not (Test-Path "$latestCmdlineDir\bin\sdkmanager.bat")) {
    New-Item -ItemType Directory -Force -Path "$sdkDir\cmdline-tools" | Out-Null
    $zipPath = "$env:TEMP\cmdline-tools.zip"
    Write-Host "Downloading Android SDK Command-Line Tools..."
    curl.exe -sSL "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip" -o $zipPath
    Write-Host "Extracting Command-Line Tools to $latestCmdlineDir..."
    Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\cmdline_extract" -Force
    if (Test-Path $latestCmdlineDir) { Remove-Item $latestCmdlineDir -Recurse -Force }
    Move-Item -Path "$env:TEMP\cmdline_extract\cmdline-tools" -Destination $latestCmdlineDir -Force
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\cmdline_extract" -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Android SDK Command-Line Tools already installed at $latestCmdlineDir"
}

Write-Host "`n=== 3. Configuring User Environment Variables ==="
[Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkDir, "User")
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkDir, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkDir, "User")

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathList = $userPath -split ';' | Where-Object { $_ -ne '' }
$pathsToAdd = @(
    "$jdkDir\bin",
    "$sdkDir\platform-tools",
    "$sdkDir\cmdline-tools\latest\bin",
    "$sdkDir\emulator"
)
foreach ($p in $pathsToAdd) {
    if ($pathList -notcontains $p) {
        $pathList += $p
    }
}
[Environment]::SetEnvironmentVariable("Path", (($pathList -join ';') + ';'), "User")

$env:JAVA_HOME = $jdkDir
$env:ANDROID_HOME = $sdkDir
$env:ANDROID_SDK_ROOT = $sdkDir
$env:Path = "$jdkDir\bin;$sdkDir\platform-tools;$sdkDir\cmdline-tools\latest\bin;$sdkDir\emulator;$env:Path"

Write-Host "`n=== 4. Installing Android SDK Packages (API 35, Build-Tools 35.0.0, Platform-Tools) ==="
1..15 | ForEach-Object { "y" } | & "$latestCmdlineDir\bin\sdkmanager.bat" --licenses | Out-Null
1..15 | ForEach-Object { "y" } | & "$latestCmdlineDir\bin\sdkmanager.bat" "platform-tools" "build-tools;35.0.0" "platforms;android-35"

Write-Host "`n=== Setup Complete ==="
& "$jdkDir\bin\java.exe" -version
& "$sdkDir\platform-tools\adb.exe" version

