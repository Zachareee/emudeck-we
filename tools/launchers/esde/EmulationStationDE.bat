@@ -1,8 +1,3 @@
@echo off
set args=%*

powershell -ExecutionPolicy Bypass -command "& { . $env:USERPROFILE/AppData/Roaming/EmuDeck/backend/functions/all.ps1 ; cloud_sync_downloadEmuAll "}
"ESDEPATH\EmulationStation.exe" %args%
cls

powershell -ExecutionPolicy Bypass -command "& { . $env:USERPROFILE/AppData/Roaming/EmuDeck/backend/functions/all.ps1 ; cloud_sync_uploadEmuAll "}
No newline at end of file
