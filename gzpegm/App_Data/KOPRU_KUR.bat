@echo off
chcp 65001 >nul
title EGM Optik Okuyucu Ortak Köprü Kurulumu
setlocal

set "SCRIPT_DIR=%~dp0"
set "TARGET_DIR=%LOCALAPPDATA%\EgmReaderBridge"
set "TARGET_EXE=%TARGET_DIR%\EgmReaderBridge.exe"
set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

echo ================================================================
echo   EGM OPTIK OKUYUCU ORTAK KOPRUSU
echo   3M / Gemalto / Thales / Regula / Desko
echo ================================================================

if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

rem Sahtecilik ve GZPCEZA ayni yerel kopruyu ve portu paylasir.
rem Calisan kopru varsa onu kapatma veya baska projeden gelen dosyayla ezme.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { $r=Invoke-RestMethod -Uri 'http://127.0.0.1:41102/status' -TimeoutSec 2; if ($r.isRunning -eq $true) { exit 0 } else { exit 1 } } catch { exit 1 }"
if not errorlevel 1 goto bridge_active

echo [1/3] Ortak optik okuyucu koprusu bu bilgisayarda baslatiliyor...
if not exist "%SCRIPT_DIR%EgmReaderBridge.exe" (
  echo [HATA] EgmReaderBridge.exe bulunamadi: %SCRIPT_DIR%
  pause
  exit /b 1
)

copy /Y "%SCRIPT_DIR%EgmReaderBridge.exe" "%TARGET_EXE%" >nul
if not exist "%TARGET_EXE%" (
  echo [HATA] Kopru dosyasi yerel bilgisayara kopyalanamadi.
  pause
  exit /b 1
)
if exist "%SCRIPT_DIR%MMMReaderDotNet20.dll" if not exist "%TARGET_DIR%\MMMReaderDotNet20.dll" copy /Y "%SCRIPT_DIR%MMMReaderDotNet20.dll" "%TARGET_DIR%\" >nul
del /F /Q "%STARTUP_DIR%\EgmReaderBridge.vbs" >nul 2>&1

rem Otomatik baslangic ve URI protokolu tum uygulamalar icin ortak.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "EgmReaderBridge" /t REG_SZ /d "\"%TARGET_EXE%\"" /f >nul 2>&1
reg add "HKCU\Software\Classes\egm-reader" /ve /d "URL:EgmReaderBridge Protocol" /f >nul 2>&1
reg add "HKCU\Software\Classes\egm-reader" /v "URL Protocol" /d "" /f >nul 2>&1
reg add "HKCU\Software\Classes\egm-reader\shell\open\command" /ve /d "\"%TARGET_EXE%\" \"%%1\"" /f >nul 2>&1

start "" "%TARGET_EXE%"
timeout /t 2 >nul
echo [TAMAM] Ortak optik okuyucu koprusu baslatildi.
echo Bu kopru Sahtecilik ve GZPCEZA sayfalarinda ortak kullanilir.
goto finish

:bridge_active
echo [TAMAM] Ortak optik okuyucu koprusu zaten calisiyor.
echo Calisan kopru durdurulmadi; Sahtecilik ve GZPCEZA ayni kopruyu kullanabilir.

:finish
echo ================================================================
endlocal
timeout /t 4 >nul
