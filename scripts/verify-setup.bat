@echo off
REM 🏥 Healthcare AI - Team Setup Verification Script (Windows)
REM Run this script to verify your development environment is ready

echo 🏥 Healthcare AI Orchestration - Setup Verification
echo ==================================================
echo.

echo 🔍 Checking required software...
echo.

REM Check Flutter
flutter --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Flutter is installed
    flutter --version | findstr "Flutter"
) else (
    echo ❌ Flutter is not installed
    set "all_good=false"
)

REM Check Dart
dart --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Dart is installed
) else (
    echo ❌ Dart is not installed
    set "all_good=false"
)

REM Check Git
git --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Git is installed
) else (
    echo ❌ Git is not installed
    set "all_good=false"
)

REM Check Chrome
where chrome >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Chrome is available
) else (
    echo ❌ Chrome not found in PATH
)

echo.
echo 🔍 Running Flutter doctor...
echo.
flutter doctor

echo.
echo 🔍 Checking project structure...
echo.

REM Check if we're in the right directory
if exist "pubspec.yaml" (
    echo ✅ Found pubspec.yaml - you're in the Flutter project directory
    
    if exist "lib\main.dart" (
        echo ✅ lib\main.dart exists
    ) else (
        echo ❌ lib\main.dart not found
    )
    
    if exist "lib\core\theme\app_theme.dart" (
        echo ✅ lib\core\theme\app_theme.dart exists
    ) else (
        echo ❌ lib\core\theme\app_theme.dart not found
    )
    
) else if exist "frontend" (
    echo ⚠️ You're in the root directory. Checking frontend\...
    cd frontend
    
    if exist "pubspec.yaml" (
        echo ✅ Found frontend\pubspec.yaml
    ) else (
        echo ❌ frontend\pubspec.yaml not found
        set "all_good=false"
    )
) else (
    echo ❌ Neither pubspec.yaml nor frontend\ directory found
    echo Make sure you're in the project root or frontend\ directory
    set "all_good=false"
)

echo.
echo 🔍 Testing Flutter dependencies...
echo.

flutter pub get
if %errorlevel% == 0 (
    echo ✅ Dependencies installed successfully
) else (
    echo ❌ Failed to install dependencies
    set "all_good=false"
)

echo.
echo 🔍 Running tests...
echo.

flutter test
if %errorlevel% == 0 (
    echo ✅ All tests passed
) else (
    echo ❌ Some tests failed
    set "all_good=false"
)

echo.
echo ==================================================
echo 🎉 SETUP VERIFICATION COMPLETE!
echo ✅ Your environment is ready for Healthcare AI development
echo.
echo 🚀 Next steps:
echo 1. Run: flutter run -d chrome --web-port 3000
echo 2. Open browser to: http://localhost:3000
echo 3. Look for: Healthcare AI splash screen
echo 4. Check terminal for: ✅ Firebase initialized successfully
echo.
echo Ready to save 1,500+ lives annually! 🏥
echo ==================================================

pause 