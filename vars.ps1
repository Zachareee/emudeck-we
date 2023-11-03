$EmuDeckStartFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\EmuDeck"
$url_ra = "https://buildbot.libretro.com/nightly/windows/x86_64/RetroArch.7z"
$url_dolphin = "https://dl.dolphin-emu.org/builds/40/56/dolphin-master-5.0-18498-x64.7z"
$url_ppsspp = "https://www.ppsspp.org/files/1_16_6/ppsspp_win.zip"
$url_esde = "https://gitlab.com/es-de/emulationstation-de/-/package_files/100303779/download"
$userFolder = "$env:USERPROFILE"
$emusPath = "$env:USERPROFILE\EmuDeck\EmulationStation-DE\Emulators"
$emusPathSRM = "$env:USERPROFILE\\EmuDeck\\EmulationStation-DE\\Emulators"
$esdePath = "$env:USERPROFILE/EmuDeck/EmulationStation-DE"
$pegasusPath = "$env:USERPROFILE/EmuDeck/Pegasus"
$temp = "$env:USERPROFILE\EmuDeck\temp"
$nssm = "$env:USERPROFILE\AppData\Roaming\EmuDeck\backend\wintools\nssm.exe"
$7z = "$env:USERPROFILE\AppData\Roaming\EmuDeck\backend\wintools\7z.exe"
#Steam installation Path
$steamRegPath = "HKCU:\Software\Valve\Steam"
$steamInstallPath = (Get-ItemProperty -Path $steamRegPath).SteamPath
$steamInstallPath = $steamInstallPath.Replace("/", "\")
$steamInstallExe = "$steamInstallPath/Steam.exe"