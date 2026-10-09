# build-topdown.ps1 — one-command build + deploy for the top-down experiment.
# Patches now land as git commits on the topdown branch (maintained by Baymax),
# so this script just configures, builds, and deploys to the game folder.
# Run from the OpenCE repo root via updater.bat (or:
#   powershell -ExecutionPolicy Bypass -File .\build-topdown.ps1)
param(
    [string]$GameDir = "E:\Games\Sierra 117"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Configuring ==="
python configure.py --release
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "=== Building ==="
ninja windows
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "=== Deploying to $GameDir ==="
if (!(Test-Path $GameDir)) { New-Item -ItemType Directory -Path $GameDir | Out-Null }
# Stock OpenCE builds halo.exe; copy it as sierra.exe for consistency
Copy-Item build\windows\halo.exe -Destination "$GameDir\sierra.exe" -Force
Copy-Item build\windows\SDL3.dll, build\windows\halo.pdb, launch-sierra.vbs `
    -Destination $GameDir -Force
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "=== Done ==="
