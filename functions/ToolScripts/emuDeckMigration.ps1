function Migration_init {
    param (
        [string]$destination
    )

    # Tamaño de los archivos en el destino
    $neededSpace = (Get-ChildItem -Recurse -ErrorAction SilentlyContinue -Path $emulationPath | Measure-Object -Property Length -Sum).Sum / 1KB
    $neededSpaceInHuman = (Get-ChildItem -Recurse -ErrorAction SilentlyContinue -Path $emulationPath | Measure-Object -Property Length -Sum).Sum / 1MB

    # Espacio libre en el destino
    $driveInfo = Get-PSDrive -Name (Get-Item $destination).PSDrive.Name
    $freeSpace = $driveInfo.Free / 1KB
    $freeSpaceInHuman = $driveInfo.Free / 1MB

    $difference = $freeSpace - $neededSpace
    if ($difference -lt 0) {

        # Mostrar un cuadro de diálogo para continuar o salir
       confirmDialog -TitleText "EmuDeck" -MessageText "Make sure you have enough space in $destination. You need to have at least $neededSpaceInHuman MB available."
    }

    # Llamar a las funciones de migración (suponiendo que estén definidas)
    Migration_move $emulationPath $destination $neededSpaceInHuman
    #Migration_updatePaths $emulationPath "$destination\Emulation\"
}

function Migration_move {

    param (
        [string]$origin,
        [string]$destination,
        [string]$size
    )

    Add-Type -AssemblyName System.Windows.Forms
    mkdir "$destination/Emulation" -ErrorAction SilentlyContinue
    # Crear el diálogo de progreso
    $progressForm = New-Object System.Windows.Forms.Form
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Value = 0
    $progressBar.Width = 350
    $progressBar.Height = 20

    $progressForm.Text = "Migrating your current $size Emulation folder to $destination"
    $progressForm.Width = 400
    $progressForm.Height = 120
    $progressForm.StartPosition = 'CenterScreen'
    $progressForm.Controls.Add($progressBar)

    $progressLabel = New-Object System.Windows.Forms.Label
    $progressLabel.Text = "Scanning..."
    $progressLabel.Top = 30
    $progressLabel.Left = 10
    $progressForm.Controls.Add($progressLabel)

    $progressForm.Show()

    # Ejecutar el comando Robocopy para migrar archivos

    $robocopyArgs = @("$origin", "$destination", "/MIR", "/Z", "/MT:16", "/R:5", "/W:5", "/NFL", "/NDL")
    $robocopyProcess = Start-Process -FilePath "robocopy" -ArgumentList $robocopyArgs -NoNewWindow -PassThru -Wait

    if ($robocopyProcess.ExitCode -lt 8) {
        # Copia exitosa (exit codes 0-7 en robocopy son advertencias menores)
        $progressBar.Value = 100
        $progressLabel.Text = "Migration completed."
    } else {
        # Error en la copia
        $progressLabel.Text = "Migration failed."
    }

    # Cerrar la ventana de progreso después de unos segundos
    Start-Sleep -Seconds 2
    $progressForm.Close()
}

function Migration_updatePaths {
    param (
        [string]$origin,
        [string]$destination
    )

    # Actualización de las nuevas rutas
    setSetting "emulationPath" $destination
    setSetting "toolsPath" "$destination/tools"
    setSetting "romsPath" "$destination/roms"
    setSetting "biosPath" "$destination/bios"
    setSetting "savesPath" "$destination/saves"
    setSetting "storagePath" "$destination/storage"
    setSetting "ESDEscrapData" "$destination/tools/downloaded_media"

    # Función para reemplazar rutas en archivos de configuración
    function Update-ConfigFile {
        param (
            [string]$configFile,
            [string]$origin,
            [string]$destination
        )

        if (Test-Path $configFile) {
            (Get-Content $configFile) -replace [regex]::Escape($origin), $destination | Set-Content $configFile
        } else {
            Write-Host "Config file not found: $configFile"
        }
    }

    # Actualización de los archivos de configuración de emuladores
    Update-ConfigFile $Azahar_configFile $origin $destination
    Update-ConfigFile $Dolphin_configFile $origin $destination
    Update-ConfigFile $DuckStation_configFileNew $origin $destination
    Update-ConfigFile $MAME_configFile $origin $destination
    Update-ConfigFile $melonDS_configFile $origin $destination
    Update-ConfigFile $mGBA_configFile $origin $destination
    Update-ConfigFile $PCSX2QT_configFile $origin $destination
    Update-ConfigFile $PPSSP_configFile $origin $destination
    Update-ConfigFile $Primehack_configFile $origin $destination
    Update-ConfigFile $RetroArch_configFile $origin $destination
    Update-ConfigFile $RMG_configFile $origin $destination
    Update-ConfigFile $RPCS3_configFile $origin $destination
    Update-ConfigFile $Ryujinx_configFile $origin $destination
    Update-ConfigFile $ScummVM_configFile $origin $destination
    Update-ConfigFile $Vita3K_configFile $origin $destination
    Update-ConfigFile $Xemu_configFile $origin $destination
    Update-ConfigFile $Xenia_XeniaSettings $origin $destination
    Update-ConfigFile $Yuzu_configFile $origin $destination

    # Llamar a la función de actualización de SRM
    Migration_updateSRM $origin $destination

    # Recargar las ubicaciones de las partidas guardadas
    Get-Command -Name "*_IsInstalled" | ForEach-Object {
        $func = $_.Name
        if (& $func) {
            $setup_func = $func -replace '_IsInstalled$', '_setupSaves'
            if (Get-Command -Name $setup_func -ErrorAction SilentlyContinue) {
                & $setup_func
            }
        }
    }


    # Mensaje de éxito
    confirmDialog -TitleText "EmuDeck" -MessageText "Your library has been moved to $destination."

    Write-Host "Valid"
}

function Migration_updateSRM {
    param (
        [string]$origin,
        [string]$destination
    )

    $steamRegPath = "HKCU:\Software\Valve\Steam"
    $steamInstallPath = (Get-ItemProperty -Path $steamRegPath).SteamPath

   # Reemplazar rutas en "shortcuts.vdf" usando Get-ChildItem para encontrar los archivos
    Get-ChildItem $steamInstallPath -Recurse -Filter "shortcuts.vdf" | ForEach-Object {
        (Get-Content $_.FullName) -replace [regex]::Escape($origin), $destination | Set-Content $_.FullName
    }

    # Actualizar "userSettings.json" con la nueva ruta de ROMs usando ConvertFrom-Json y ConvertTo-Json
    $settingsFile = "$toolsPath\userData\userSettings.json"
    $settings = Get-Content $settingsFile | ConvertFrom-Json
    $settings.environmentVariables.romsDirectory = $romsPath
    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile

    SRM_init
}

function Migration_ESDE {
    ESDE_setEmulationFolder
}



#Migration_init "C:/users/rsedano/Desktop/bios"