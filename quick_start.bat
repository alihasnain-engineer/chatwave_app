@echo off
echo ========================================
echo   ChatWave App - Quick Start Script
echo ========================================
echo.

echo [1/4] Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)
echo ✓ Clean completed
echo.

echo [2/4] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies!
    pause
    exit /b 1
)
echo ✓ Dependencies installed
echo.

echo [3/4] Checking Flutter setup...
call flutter doctor
echo.

echo [4/4] Analyzing code...
call flutter analyze
if %errorlevel% neq 0 (
    echo WARNING: Code analysis found issues!
    echo Please fix them before running the app.
    pause
    exit /b 1
)
echo ✓ No issues found!
echo.

echo ========================================
echo   Ready to run! Choose an option:
echo ========================================
echo.
echo 1. Run on connected device/emulator
echo 2. Build release APK
echo 3. Exit
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    echo.
    echo Starting app...
    call flutter run
) else if "%choice%"=="2" (
    echo.
    echo Building release APK...
    call flutter build apk --release
    echo.
    echo ✓ APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
) else (
    echo Exiting...
    exit /b 0
)

pause
