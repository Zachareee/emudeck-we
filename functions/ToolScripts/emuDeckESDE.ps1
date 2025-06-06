function ESDE_install(){
	setMSG 'Downloading EmulationStation DE'

	#Fixes for ESDE warning message
	if ( ESDE_IsInstalled -like "*true*" ){
		if (Test-Path -Path "$esdePath\ES-DE\gamelists") {
			moveFromTo "$esdePath\ES-DE\gamelists" "$temp\gamelists"
		}
		if (Test-Path -Path "$esdePath\.emulationstation\gamelists") {
			moveFromTo "$esdePath\.emulationstation\gamelists" "$temp\gamelists"
		}
		ESDE_uninstall
		$doInit="true"
	}

	rm -r -fo "$temp/esde" -ErrorAction SilentlyContinue
	download $url_esde "esde.zip"
	mkdir $esdePath -ErrorAction SilentlyContinue

	moveFromTo "$temp/esde/ES-DE" "$esdePath"

	if($doInit -eq "true" ){
		ESDE_init
	}else{
		ESDE_addToSteam
	}


}

function ESDE_init(){
	setMSG 'EmulationStation DE - Paths and Themes'


	$ESDE_oldConfigDirectory="$esdePath\.emulationstation"
	$ESDE_newConfigDirectory="$esdePath\ES-DE"
	if (Test-Path -Path $ESDE_oldConfigDirectory) {
		Rename-Item $ESDE_oldConfigDirectory $ESDE_newConfigDirectory
		Write-Output "EmulationStation-DE config directory successfully migrated and linked."
	}


	if(Test-Path "$esdePath\ES-DE\gamelists"){
		moveFromTo "$esdePath\ES-DE\gamelists" "$temp\gamelists"
	}

	if(Test-Path "$esdePath\.emulationstation\gamelists"){
		moveFromTo "$esdePath\ES-DE\gamelists" "$temp\gamelists"
	}
	#We reset ESDE system files
	#Copy-Item "$esdePath/resources/systems/windows/es_systems.xml.bak" -Destination "$esdePath/resources/systems/windows/es_systems.xml" -ErrorAction SilentlyContinue
	#Copy-Item "$esdePath/resources/systems/windows/es_find_rules.xml.bak" -Destination "$esdePath/resources/systems/windows/es_find_rules.xml" -ErrorAction SilentlyContinue

	#We move ESDE + Emus to the userfolder.
	$test=Test-Path -Path "$toolsPath\EmulationStation-DE\ES-DE.exe"
	if($test){

		$userDrive="$userFolder[0]"

		$destinationFree = (Get-PSDrive -Name "$userDrive").Free
		$sizeInGB = [Math]::Round($destinationFree / 1GB)

		$originSize = (Get-ChildItem -Path "$toolsPath/EmulationStation-DE" -Recurse | Measure-Object -Property Length -Sum).Sum
		$wshell = New-Object -ComObject Wscript.Shell

		if ( $originSize -gt $destinationFree ){
			$Output = $wshell.Popup("You don't have enough space in your $userDrive drive, free at least $sizeInGB GB")
			exit
		}
		$Output = $wshell.Popup("We are going to move EmulationStation and all the Emulators to $userFolder in order to improve loading times. This will take long, so please wait until you get a new confirmation window")

		mkdir $esdePath  -ErrorAction SilentlyContinue
		moveFromTo "$toolsPath\EmulationStation-DE" "$esdePath"

		$Output = $wshell.Popup("Migration complete!")

	}

	#We move download_media folder
	$test=Test-Path -Path "$emudeckFolder\EmulationStation-DE\ES-DE\downloaded_media"
	if($test){

		$userDrive="$userFolder[0]"

		$destinationFree = (Get-PSDrive -Name $userDrive).Free
		$sizeInGB = [Math]::Round($destinationFree / 1GB)

		$originSize = (Get-ChildItem -Path "$toolsPath/EmulationStation-DE" -Recurse | Measure-Object -Property Length -Sum).Sum
		$wshell = New-Object -ComObject Wscript.Shell

		if ( $originSize -gt $destinationFree ){
			$Output = $wshell.Popup("You don't have enough space in your $userDrive drive, free at least $sizeInGB GB")
			exit
		}
		$Output = $wshell.Popup("We are going to move EmulationStation scrape data to $emulationPath/storage in order to free space in your internal drive. This could take long, so please wait until you get a new confirmation window")

		mkdir "$emulationPath/storage/downloaded_media"  -ErrorAction SilentlyContinue
		moveFromTo "$esdePath/ES-DE/downloaded_media" "$emulationPath/storage/downloaded_media"

		$Output = $wshell.Popup("Migration complete!")

	}

	$destination="$esdePath\ES-DE"
	mkdir $destination -ErrorAction SilentlyContinue
	copyFromTo "$env:APPDATA\EmuDeck\backend\configs\emulationstation" "$destination"

	$xml = Get-Content "$esdePath\ES-DE\es_settings.xml"
	$updatedXML = $xml -replace '(?<=<string name="ROMDirectory" value=").*?(?=" />)', "$romsPath"
	$updatedXML | Set-Content "$esdePath\ES-DE\es_settings.xml" -Encoding UTF8

	mkdir "$emulationPath/storage/downloaded_media" -ErrorAction SilentlyContinue

	$xml = Get-Content "$esdePath\ES-DE\es_settings.xml"
	$updatedXML = $xml -replace '(?<=<string name="MediaDirectory" value=").*?(?=" />)', "$emulationPath/storage/downloaded_media"
	$updatedXML | Set-Content "$esdePath\ES-DE\es_settings.xml" -Encoding UTF8

	mkdir "$toolsPath\launchers\esde" -ErrorAction SilentlyContinue
	SRM_resetLaunchers #ESDE3.0 fix
	createLauncher "esde/EmulationStationDE"

	ESDE_applyTheme "$esdeThemeUrl" "$esdeThemeName"

	ESDE_setDefaultEmulators

	if(Test-Path "$temp\gamelists"){
		rm -r -fo "$esdePath\ES-DE\gamelists"
		mkdir "$esdePath\ES-DE\gamelists" -ErrorAction SilentlyContinue
		moveFromTo "$temp\gamelists" "$esdePath\ES-DE\gamelists"
		rm -r -fo "$temp\gamelists"
	}

}

function ESDE_refreshCustomEmus(){
	copyFromTo "$emudeckFolder\backend\configs\emulationstation\custom_systems" "$emudeckFolder\EmulationStation-DE\ES-DE\custom_systems"
}

function ESDE_addLauncher($emucode, $launcher){

	# Configuration file path
	$configFile = "$esdePath/resources/systems/windows/es_find_rules.xml"

	# Emulator name
	$emulatorName = "$emucode"

	# New entry to add
	$newEntry = "$toolsPath\launchers\$launcher.bat"

	# Load the XML content
	$xmlContent = Get-Content $configFile -Raw

	# Create an XML object from the content
	$xml = [xml]$xmlContent

	# Find the emulator by name
	$emulator = Select-Xml -Xml $xml -XPath "//emulator[@name='$emulatorName']"

	# Check if the emulator was found
	if ($emulator -eq $null) {
		Write-Host "No emulator found with the name '$emulatorName'."
	} else {
		# Add the new entry to the rule
		$newEntryElement = $xml.CreateElement("entry")
		$newEntryElement.InnerText = $newEntry
		$emulator.Node.rule.prependChild($newEntryElement)

		# Save the changes to the file
		$xml.Save($configFile)

		Write-Host "The new entry has been added successfully."
	}

}

function ESDE_update(){
	Write-Output "NYI"
}
function ESDE_setEmulationFolder(){
	Write-Output "NYI"
}
function ESDE_setupSaves(){
	Write-Output "NYI"
}
function ESDE_setupStorage(){
	Write-Output "NYI"
}
function ESDE_wipe(){
	Write-Output "NYI"
}
function ESDE_uninstall(){
	$testpath = Test-Path -Path "$esdepath"
	if ($testpath -eq $True){
		Get-ChildItem -Path "$esdePath" | Where-Object { $_.Name -ne "Emulators" } | Remove-Item -Recurse -Force
		if($?){
			Write-Output "True"
		}
	}
	else{
		Write-Output "False"
	}

}
function ESDE_migrate(){
	Write-Output "NYI"
}
function ESDE_setABXYstyle(){
	Write-Output "NYI"
}
function ESDE_wideScreenOn(){
	Write-Output "NYI"
}
function ESDE_wideScreenOff(){
	Write-Output "NYI"
}
function ESDE_bezelOn(){
	Write-Output "NYI"
}
function ESDE_bezelOff(){
	Write-Output "NYI"
}
function ESDE_finalize(){
	Write-Output "NYI"
}

function ESDE_applyTheme($esdeThemeUrl, $esdeThemeName ){

	mkdir -p "$esdePath\ES-DE\themes" -ErrorAction SilentlyContinue
	cd "$esdePath\ES-DE\themes"
	git clone $esdeThemeUrl "./$esdeThemeName"

	$xml = Get-Content "$esdePath\ES-DE\es_settings.xml"
	$updatedXML = $xml -replace '(?<=<string name="ThemeSet" value=").*?(?=" />)', "$esdeThemeName"
	$updatedXML | Set-Content "$esdePath\ES-DE\es_settings.xml" -Encoding UTF8

}

function ESDE_IsInstalled(){
	$test=Test-Path -Path "$esdePath\ES-DE.exe"
	$testold=Test-Path -Path "$toolsPath/EmulationStation-DE"
	if ($test -or $testold) {
		Write-Output "true"
	}else{
		Write-Output "false"
	}

}
function ESDE_resetConfig(){
	ESDE_init
	if($?){
		Write-Output "true"
	}
}



function ESDE_setDefaultEmulators(){
	mkdir "$esdePath/ES-DE/gamelists/"  -ErrorAction SilentlyContinue

	ESDE_setEmu 'Dolphin (Standalone)' gc
	ESDE_setEmu 'PPSSPP (Standalone)' psp
	ESDE_setEmu 'Dolphin (Standalone)' wii
	ESDE_setEmu 'PCSX2 (Standalone)' ps2
	ESDE_setEmu 'melonDS' nds
	ESDE_setEmu 'Azahar (Standalone)' n3ds
	ESDE_setEmu 'Beetle Lynx' atarilynx
	ESDE_setEmu 'DuckStation (Standalone)' psx
	ESDE_setEmu 'Beetle Saturn' saturn
	ESDE_setEmu 'ScummVM (Standalone)' scummvm
}


function ESDE_setEmu($emu, $system){
    $gamelistFile="$esdePath/ES-DE/gamelists/$system/gamelist.xml"
	$test=Test-Path -Path "gamelistFile"

	if ( Test-Path -Path "$gamelistFile" ){

		echo "we do nothing"
		#$xml = [xml](Get-Content $gamelistFile)

		#$xml.alternativeEmulator.label = $emu

		# Guardar los cambios en el archivo XML
		#$xml.Save($gamelistFile)

	}
	else{

		mkdir "$esdePath/ES-DE/gamelists/$system"  -ErrorAction SilentlyContinue

		"$env:APPDATA\EmuDeck\backend\configs\emulationstation"

		Copy-Item "$env:APPDATA\EmuDeck\backend\configs\emulationstation/gamelists/$system/gamelist.xml" -Destination "$gamelistFile" -ErrorAction SilentlyContinue -Force
	}

}

function ESDE_addToSteam(){
	setMSG "Adding $ESDE_toolName to Steam"
	add_to_steam 'es-de' 'EmulationStationDE' "$toolsPath\launchers\esde\EmulationStationDE.ps1" "$esdePath" "$emudeckFolder\backend\tools\launchers\icons\EmulationStationDE.ico"
}