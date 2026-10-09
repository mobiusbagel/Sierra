@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ========================================
echo   Sierra 117 - Release Packager
echo ========================================
echo.

:: Read version from VERSION file
if not exist "%~dp0VERSION" (
    echo ERROR: VERSION file not found in %~dp0
    pause
    exit /b 1
)
set /p SIERRA_VERSION=<"%~dp0VERSION"
echo Version: !SIERRA_VERSION!
echo.

:: Determine game directory
set "GAME_DIR=E:\Games\Sierra 117"
if exist "%~dp0.sierra-gamedir" (
    set /p GAME_DIR=<"%~dp0.sierra-gamedir"
)
echo Game directory: !GAME_DIR!
echo.

:: Verify all 7 files exist
set "MISSING=0"
echo Checking files...
if not exist "!GAME_DIR!\sierra.exe" (echo   MISSING: sierra.exe & set "MISSING=1")
if not exist "!GAME_DIR!\SDL3.dll" (echo   MISSING: SDL3.dll & set "MISSING=1")
if not exist "!GAME_DIR!\sierra.pdb" (echo   MISSING: sierra.pdb & set "MISSING=1")
if not exist "%~dp0launch-sierra.vbs" (echo   MISSING: launch-sierra.vbs & set "MISSING=1")
if not exist "%~dp0SierraUpdater.ps1" (echo   MISSING: SierraUpdater.ps1 & set "MISSING=1")
if not exist "%~dp0launch-sierra-updater.vbs" (echo   MISSING: launch-sierra-updater.vbs & set "MISSING=1")
if not exist "%~dp0VERSION" (echo   MISSING: VERSION & set "MISSING=1")

if "!MISSING!"=="1" (
    echo.
    echo ERROR: Some files are missing. Build first with updater.bat.
    pause
    exit /b 1
)
echo   All 7 files found.
echo.

:: Create staging directory
set "STAGE=%TEMP%\sierra-package-!SIERRA_VERSION!"
if exist "!STAGE!" rmdir /s /q "!STAGE!"
mkdir "!STAGE!"

:: Copy files to staging
echo Copying files...
copy "!GAME_DIR!\sierra.exe" "!STAGE!\" >nul
copy "!GAME_DIR!\SDL3.dll" "!STAGE!\" >nul
copy "!GAME_DIR!\sierra.pdb" "!STAGE!\" >nul
copy "%~dp0launch-sierra.vbs" "!STAGE!\" >nul
copy "%~dp0SierraUpdater.ps1" "!STAGE!\" >nul
copy "%~dp0launch-sierra-updater.vbs" "!STAGE!\" >nul
copy "%~dp0VERSION" "!STAGE!\" >nul
echo   Done.
echo.

:: Create zip using PowerShell
set "ZIP_NAME=sierra-windows-release.zip"
set "ZIP_PATH=%~dp0!ZIP_NAME!"
if exist "!ZIP_PATH!" del "!ZIP_PATH!"

echo Creating !ZIP_NAME!...
powershell -NoProfile -Command "Compress-Archive -Path '!STAGE!\*' -DestinationPath '!ZIP_PATH!' -Force"
if !errorlevel! neq 0 (
    echo ERROR: Failed to create zip.
    pause
    exit /b 1
)

:: Cleanup
rmdir /s /q "!STAGE!"

echo.
echo ========================================
echo   Package complete!
echo.
echo   File: !ZIP_PATH!
echo   Version: !SIERRA_VERSION!
echo.
echo   Upload this to the v!SIERRA_VERSION! GitHub release.
echo ========================================
pause
