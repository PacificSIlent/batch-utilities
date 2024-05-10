MODE CON COLS=128 LINES=1000
@ECHO OFF
setlocal EnableExtensions EnableDelayedExpansion

set "zip=C:\Program Files\7-Zip\7z.exe"

:: Ryujinx Save File Directory
set "ryujinx_save_file_directory=C:\Users\jgall\OneDrive\Escritorio\ryujinxdata\bis\user\save"

:: GDrive Save File Directory
set "gdrive_save_file_directory=C:\Users\jgall\OneDrive\Escritorio\PC_Ryujinx_Backup"
set "cloud_gdrive_folder=F:\SyncDrive\PC_Ryujinx_Backup"


:: Array Of Game Save Directory Paths
set /a i=1
set switch_save_directories[0].title=Transfer All Game Saves [Backup Your Save Files First]

:: The Legend of Zelda: Breath of the Wild
set switch_save_directories[!i!].title=The Legend of Zelda Breath of the Wild
set "switch_save_directories[!i!].ryujinx=%ryujinx_save_file_directory%\0000000000000007\0"
set "switch_save_directories[!i!].gdrive=%gdrive_save_file_directory%\PC - The Legend of Zelda Breath of the Wild"
call :AddAboveGame
:: Kimetsu no Yaiba
set switch_save_directories[!i!].title=Kimetsu no Yaiba
set "switch_save_directories[!i!].ryujinx=%ryujinx_save_file_directory%\0000000000000008\0"
set "switch_save_directories[!i!].gdrive=%gdrive_save_file_directory%\PC - Kimetsu no Yaiba"
call :AddAboveGame
:: Crash CTR
set switch_save_directories[!i!].title=Crash CTR
set "switch_save_directories[!i!].ryujinx=%ryujinx_save_file_directory%\0000000000000009\0"
set "switch_save_directories[!i!].gdrive=%gdrive_save_file_directory%\PC - Crash CTR"
call :AddAboveGame
:: Luigi's Mansion 3
set switch_save_directories[!i!].title=Luigis Mansion 3
set "switch_save_directories[!i!].ryujinx=%ryujinx_save_file_directory%\0000000000000004\0"
set "switch_save_directories[!i!].gdrive=%gdrive_save_file_directory%\PC - Luigis Mansion 3"
call :AddAboveGame
:: Prince of Persia: The Lost Crown
set switch_save_directories[!i!].title=Prince of Persia The Lost Crown
set "switch_save_directories[!i!].ryujinx=%ryujinx_save_file_directory%\000000000000000b\0"
set "switch_save_directories[!i!].gdrive=%gdrive_save_file_directory%\PC - Prince of Persia The Lost Crown"
call :AddAboveGame

set transfer_from.indexes=1
set transfer_from[1]=Ryujinx to GDrive

call echo/
call echo  Game Save Transfer Script
call echo  Used to transfer save files from Ryujinx to GDrive.
call echo/

call :Start
:: Menu Loop
:Start
    call echo ================================================================
    for %%i in (0 %switch_save_directories.indexes%) do (
        call echo   [!check%%i!] %%i. !switch_save_directories[%%i].title!
        if %%i==0 (
            call echo ================================================================
        )
    )
    call echo ================================================================
    set /p game="--> Which game save files do you wish to transfer? Enter # "
    call echo/
    
    if "!game!"=="0" (
        call echo     You chose to transfer [All] save game files from Ryujinx.
        call echo     Are you absolutely sure because you can easily overwrite files you might not intend to?
        set /p confirm="--> Have you backed up all your game saves and ready to proceed? [y/n]
        set transfer_all=True
    ) else (
        call echo     You chose to transfer [!switch_save_directories[%game%].title!] save game files from Ryujinx.
        set /p confirm="--> Is this correct? [y/n]"
        set transfer_all=False
        call echo/
    )
    
    if "!confirm!"=="y" (
        if "!transfer_all!"=="True" (
            call :TransferAllSaveFilesFrom
            call :ZipAllSaveFiles
        ) else (
            call :TransferSaveFilesFrom "!game!"
            call :ZipSaveFiles "!switch_save_directories[%game%].gdrive!"
        )
    ) else (
    if "!confirm!"=="Y" (
        if "!transfer_all!"=="True" (
            call :TransferAllSaveFilesFrom
            call :ZipAllSaveFiles
        ) else (
            call :TransferSaveFilesFrom "!game!"
            call :ZipSaveFiles "!switch_save_directories[%game%].gdrive!"
        )
    ) else (
        call :Start
    ))

    call :TransferToCloud


    EXIT
    exit /b 0


:TransferSaveFilesFrom
    set "copy_folder=!switch_save_directories[%~1].ryujinx!"
    set "paste_folder=!switch_save_directories[%~1].gdrive!"
    robocopy /E "!copy_folder!" "!paste_folder!"
    exit /b 0

:TransferAllSaveFilesFrom
    for %%i in (%switch_save_directories.indexes%) do (
        set "copy_folder=!switch_save_directories[%%i].ryujinx!"
        set "paste_folder=!switch_save_directories[%%i].gdrive!"
        robocopy /E "!copy_folder!" "!paste_folder!"
    )
    exit /b 0

:ZipAllSaveFiles
    for /D %%i in ("%gdrive_save_file_directory%\*") do (

        dir "%%i\*" /A-D /B > nul 2>&1
        if not errorlevel 1 (
            :: (YYYY.MM.DD)
            for /F "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do (
                set "dt=%%a"
                set "date=!dt:~0,4!.!dt:~4,2!.!dt:~6,2!"
            )

            :: (HH.mm.ss)
            for /F "tokens=1-3 delims=:.," %%a in ("%TIME%") do (
                set "time=%%a.%%b.%%c"
            )

            set "customZipName=Jona-PC - !date! @ !time!.zip"

            "%zip%" a "%%i\!customZipName!" "%%i\*" -x^^!*.zip
        )
    )

    for /D /R "%gdrive_save_file_directory%" %%i in (*) do (
        for %%f in ("%%i\*") do (
            if not "%%~xf"==".zip" del "%%f"
        )
        rd "%%i" 2>nul
    )
    exit /b 0

:ZipSaveFiles 
    dir "%~1\*" /A-D /B > nul 2>&1
    if not errorlevel 1 (
        :: (YYYY.MM.DD)
        for /F "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do (
            set "dt=%%a"
            set "date=!dt:~0,4!.!dt:~4,2!.!dt:~6,2!"
        )

        :: (HH.mm.ss)
        for /F "tokens=1-3 delims=:.," %%a in ("%TIME%") do (
            set "time=%%a.%%b.%%c"
        )

        set "customZipName=Jona-PC - !date! @ !time!.zip"
        "%zip%" a "%~1\!customZipName!" "%~1\*" -x^^!*.zip

        for %%f in ("%~1\*") do (
            if /I not "%%~xf"==".zip" (
                del "%%f" /Q
            )
        )

        for /d %%d in ("%~1\*") do (
            rd "%%d" /S /Q
        )
    )

    exit /b 0

:TransferToCloud
    set "copy_folder=%gdrive_save_file_directory%"
    set "paste_folder=%cloud_gdrive_folder%"
    robocopy /E "!copy_folder!" "!paste_folder!"
    exit /b 0

:AddAboveGame
    set "switch_save_directories.indexes=!switch_save_directories.indexes!!i! "
    set /a i=i+1
    exit /b 0
