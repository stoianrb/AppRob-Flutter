@echo off
title BUILD APK - Approb
color 0F
setlocal

:: Navigare în directorul curent al scriptului
cd /d "%~dp0"

echo.
echo =============================
echo === BUILD APK - Approb ===
echo =============================
echo.

:: Curățare proiect
echo 🔄 Cleaning project...
flutter clean
IF %ERRORLEVEL% NEQ 0 GOTO error

:: Obține dependințe
echo 📦 Getting dependencies...
flutter pub get
IF %ERRORLEVEL% NEQ 0 GOTO error

:: Build APK release
echo 🏗️  Building APK (release mode)...
flutter build apk --release
IF %ERRORLEVEL% NEQ 0 GOTO error

:: Succes
echo.
echo ✅ BUILD COMPLET!
echo 🔗 APK generat: build\app\outputs\flutter-apk\app-release.apk
pause
exit /b

:error
echo.
echo ❌ EROARE! Ceva a mers prost. Verifică logurile de mai sus.
pause
