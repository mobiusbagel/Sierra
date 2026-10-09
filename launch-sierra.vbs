' launch-sierra.vbs - Tiny Sierra launcher with feedback
' Shows a popup while the game starts, then exits. Does not block.

Set ws = CreateObject("WScript.Shell")

' Show "Launching..." popup for 2 seconds (auto-dismisses)
' 64 = info icon
ws.Popup "Launching Sierra...", 2, "Sierra", 64

' Launch sierra.exe without waiting (False = don't wait for exit)
' 1 = normal window focus
ws.Run """E:\Games\Halo - Combat Evolved\Sierra\sierra.exe""", 1, False
