$EmuDeckStartFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\EmuDeck"

#Fixed emu urls
$url_ra = "https://buildbot.libretro.com/nightly/windows/x86_64/RetroArch.7z"
$url_dolphin = "https://dl.dolphin-emu.org/builds/24/4e/dolphin-master-5.0-21088-x64.7z"
$url_ppsspp = "https://www.ppsspp.org/files/1_17_1/ppsspp_win.zip"
$url_esde = "https://gitlab.com/es-de/emulationstation-de/-/package_files/164503025/download"
$url_scummVM = "https://downloads.scummvm.org/frs/scummvm/2.7.1/scummvm-2.7.1-win32-x86_64.zip"

$userFolder = "D:\\Emulation"
$emusPath = "$userFolder\Emulators"
$emusPathSRM = "$userFolder\\Emulators"
$esdePath = "$userFolder/EmulationStation-DE"
$pegasusPath = "$userFolder/EmuDeck/Pegasus"
$temp = "$userFolder\EmuDeck\temp"
$nssm = "$userFolder\EmuDeck\backend\wintools\nssm.exe"
$7z = "$userFolder\EmuDeck\backend\wintools\7z.exe"
#Steam installation Path
$steamRegPath = "HKCU:\Software\Valve\Steam"
$steamInstallPath = (Get-ItemProperty -Path $steamRegPath).SteamPath
$steamInstallPath = $steamInstallPath.Replace("/", "\")
$steamInstallPathSRM = $steamInstallPath.Replace("\", '\\')
$steamInstallExe = "$steamInstallPath/Steam.exe"
