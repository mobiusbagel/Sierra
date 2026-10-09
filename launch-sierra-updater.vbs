' Sierra 117 Launcher - runs the auto-updater hidden, then launches the game
' Shortcuts point here instead of sierra.exe directly.

Set objShell = CreateObject("Wscript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the game directory (where this script lives)
strGameDir = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Run the updater PowerShell script hidden (no console window)
strCmd = "powershell -NoProfile -ExecutionPolicy Bypass -File """ & strGameDir & "\SierraUpdater.ps1"" -GameDir """ & strGameDir & """"
objShell.Run strCmd, 0, False
