@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
echo === Sierra Updater ===
echo.
echo [1/2] Pulling latest from GitHub...
git fetch origin sierra-dev
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Git fetch failed. Check your internet connection.
    pause
    exit /b 1
)
git reset --hard origin/sierra-dev
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Git reset failed.
    pause
    exit /b 1
)
echo.
echo [2/2] Building...
:: Use saved game dir if the installer wrote one
set "GAMEDIR_ARG="
if exist "%~dp0.sierra-gamedir" (
    set /p SAVED_GAME_DIR=<"%~dp0.sierra-gamedir"
    if not "!SAVED_GAME_DIR!"=="" set "GAMEDIR_ARG=-GameDir "!SAVED_GAME_DIR!""
)
powershell -ExecutionPolicy Bypass -File "%~dp0build-dev.ps1" !GAMEDIR_ARG!
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Build failed.
    pause
    exit /b 1
)
echo.
echo === Update complete! Run sierra.exe from your game folder to play. ===
pause
