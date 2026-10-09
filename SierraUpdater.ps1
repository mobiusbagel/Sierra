# Sierra 117 Auto-Updater
# Checks GitHub for new releases, downloads and installs if available, then launches the game.
# Called by launch-sierra.vbs (hidden, no console window).

param(
    [string]$GameDir = $PSScriptRoot
)

$ErrorActionPreference = "Stop"
$Repo = "mobiusbagel/Sierra"

try {
    # Get local version
    $versionFile = Join-Path $GameDir "VERSION"
    $localVersion = ""
    if (Test-Path $versionFile) {
        $localVersion = (Get-Content $versionFile -Raw).Trim()
    }

    # Check GitHub for latest release
    $apiUrl = "https://api.github.com/repos/$Repo/releases/latest"
    $latest = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 15
    $remoteVersion = $latest.tag_name -replace '^v', ''

    if ($remoteVersion -ne $localVersion -and $remoteVersion -ne "") {
        # New version available - download and install
        $zipUrl = "https://github.com/$Repo/releases/download/v$remoteVersion/sierra-windows-release.zip"
        $zipPath = Join-Path $env:TEMP "sierra-update-$remoteVersion.zip"

        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -TimeoutSec 120

        # Extract over the game directory (overwrites sierra.exe, DLLs, etc.)
        # Do NOT touch: maps/, config.toml, *.log, *.txt, the ISO
        Expand-Archive -Path $zipPath -DestinationPath $GameDir -Force
        Remove-Item $zipPath -Force

        # Update local version marker
        $remoteVersion | Out-File $versionFile -NoNewline
    }
}
catch {
    # If update check fails (no internet, etc.), just launch the game anyway
    # Write to a log for debugging
    $logFile = Join-Path $GameDir "updater.log"
    "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Update check failed: $_" | Out-File $logFile -Append
}

# Launch the game (controller should already be connected)
$exePath = Join-Path $GameDir "sierra.exe"
if (Test-Path $exePath) {
    Start-Process -FilePath $exePath -WorkingDirectory $GameDir
}
