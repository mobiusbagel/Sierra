; Sierra 117 Installer - No prerequisites except the Xbox ISO
; Build with NSIS 3.x: right-click -> Compile NSIS Script
; Downloads pre-built sierra.exe from GitHub releases
;
; Version is read from the VERSION file in the repo.
; Update VERSION (Major.Minor.Patch) for each release.

!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"

!define SIERRA_VERSION "0.2.0"
Name "Sierra 117 ${SIERRA_VERSION}"
OutFile "Sierra117-Setup-${SIERRA_VERSION}.exe"
InstallDir "$PROGRAMFILES\Sierra 117"
RequestExecutionLevel admin
ShowInstDetails show

Var Dialog
Var IsoPathText
Var IsoBrowseBtn
Var IsoPath

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
Page custom IsoPickerPage IsoPickerLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

Function IsoPickerPage
    nsDialogs::Create 1018
    Pop $Dialog
    ${If} $Dialog == error
        Abort
    ${EndIf}
    ${NSD_CreateLabel} 0 10u 100% 20u "Select your Halo: Combat Evolved Xbox disc image (.iso or .xiso):"
    Pop $0
    ${NSD_CreateText} 0 35u 80% 14u ""
    Pop $IsoPathText
    ${NSD_SetText} $IsoPathText "$PROFILE\Downloads"
    ${NSD_CreateButton} 82% 33u 18% 18u "Browse..."
    Pop $IsoBrowseBtn
    ${NSD_OnClick} $IsoBrowseBtn OnIsoBrowse
    ${NSD_CreateLabel} 0 60u 100% 40u "You need your own legally obtained Xbox disc image. The installer will copy it into your game folder."
    Pop $0
    nsDialogs::Show
FunctionEnd

Function OnIsoBrowse
    ; Use PowerShell for a reliable file picker (nsDialogs has quirks)
    nsExec::ExecToStack 'powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.Title = \"Select your Halo:CE Xbox ISO\"; $f.Filter = \"Disc images (*.iso;*.xiso)|*.iso;*.xiso|All files (*.*)|*.*\"; $f.InitialDirectory = [Environment]::GetFolderPath(\"UserProfile\") + \"\\Downloads\"; if ($f.ShowDialog() -eq \"OK\") { $f.FileName }"'
    Pop $0  ; return code
    Pop $IsoPath
    ${If} $IsoPath != ""
        ${NSD_SetText} $IsoPathText $IsoPath
    ${EndIf}
FunctionEnd

Function IsoPickerLeave
    ${NSD_GetText} $IsoPathText $IsoPath
    ${If} $IsoPath == ""
        MessageBox MB_OK "Please select your Halo:CE Xbox ISO to continue."
        Abort
    ${EndIf}
FunctionEnd

Section "Sierra 117" SecMain
    SetOutPath "$INSTDIR"
    ; Game installs directly to $INSTDIR

    ; Download pre-built binary from latest GitHub release via PowerShell
    DetailPrint "Downloading Sierra 117 (latest build)..."
    nsExec::ExecToLog 'powershell -NoProfile -Command "Invoke-WebRequest -Uri https://github.com/mobiusbagel/Sierra/releases/download/v${SIERRA_VERSION}/sierra-windows-release.zip -OutFile $env:TEMP\sierra-windows-release.zip"'
    Pop $0
    ${If} $0 != "0"
        MessageBox MB_OK "Download failed. Check your internet connection and try again."
        Abort
    ${EndIf}

    ; Extract to game folder
    DetailPrint "Extracting..."
    nsExec::ExecToLog 'powershell -NoProfile -Command "Expand-Archive -Path \"$TEMP\\sierra-windows-release.zip\" -DestinationPath \"$INSTDIR\" -Force"'
    Delete "$TEMP\sierra-windows-release.zip"

    ; Copy the ISO
    DetailPrint "Copying Xbox ISO..."
    CopyFiles "$IsoPath" "$INSTDIR\"

    ; Shortcuts
    DetailPrint "Creating shortcuts..."
    ; Write version marker for the auto-updater
    FileOpen $1 "$INSTDIR\VERSION" w
    FileWrite $1 "${SIERRA_VERSION}"
    FileClose $1

    CreateDirectory "$SMPROGRAMS\Sierra 117"
    CreateShortcut "$SMPROGRAMS\Sierra 117\Sierra 117.lnk" "$INSTDIR\launch-sierra-updater.vbs"
    CreateShortcut "$DESKTOP\Sierra 117.lnk" "$INSTDIR\launch-sierra-updater.vbs"

    WriteUninstaller "$INSTDIR\uninstall.exe"
    DetailPrint "Done!"
SectionEnd

Section "Uninstall"
    Delete "$SMPROGRAMS\Sierra 117\Sierra 117.lnk"
    Delete "$DESKTOP\Sierra 117.lnk"
    RMDir "$SMPROGRAMS\Sierra 117"
    RMDir /r "$INSTDIR"
SectionEnd
