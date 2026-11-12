@echo off
chcp 65001 >nul
title EGM Optik Okuyucu Koprusu Kurulumu
echo ================================================================
echo   EGM PASAPORT VE ADLI BELGE INCELEME SISTEMI
echo   Masaustu Optik Okuyucu Koprusu Kurulumu (3M & Regula)
echo ================================================================
echo.

set SCRIPT_DIR=%~dp0
set TARGET_DIR=%LOCALAPPDATA%\EgmReaderBridge
set STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set TARGET_EXE=%TARGET_DIR%\EgmReaderBridge.exe

echo [1/3] Mevcut kopru ve eski servisler temizleniyor...
taskkill /F /IM EgmReaderBridge.exe >nul 2>&1
taskkill /F /IM OutputWedgeSysTray.exe >nul 2>&1
taskkill /F /IM OutputWedge.exe >nul 2>&1
del /F /Q "%STARTUP_DIR%\EgmReaderBridge.vbs" >nul 2>&1
timeout /t 1 >nul

echo [2/3] Kopru dosyalari yerel sisteme yukleniyor (Yonetici yetkisi gerekmez)...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
copy /Y "%SCRIPT_DIR%EgmReaderBridge.exe" "%TARGET_DIR%\" >nul
if exist "%SCRIPT_DIR%MMMReaderDotNet20.dll" copy /Y "%SCRIPT_DIR%MMMReaderDotNet20.dll" "%TARGET_DIR%\" >nul

:: Registry Otomatik Baslangic (HKCU - Admin istemez)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "EgmReaderBridge" /t REG_SZ /d "\"%TARGET_EXE%\"" /f >nul 2>&1

:: egm-reader:// Ozel Protokol Kaydi
reg add "HKCU\Software\Classes\egm-reader" /ve /d "URL:EgmReaderBridge Protocol" /f >nul 2>&1
reg add "HKCU\Software\Classes\egm-reader" /v "URL Protocol" /d "" /f >nul 2>&1
reg add "HKCU\Software\Classes\egm-reader\shell\open\command" /ve /d "\"%TARGET_EXE%\"" /f >nul 2>&1

echo [3/3] Optik okuyucu koprusu arka planda baslatiliyor...
start "" "%TARGET_EXE%"

echo.
echo ================================================================
echo  [BASARILI] Optik okuyucu koprusu kuruldu ve arka planda calisiyor!
echo.
echo  * Siyah komut penceresi KESINLIKLE acilmaz; tamamen sessiz calisir.
echo  * Bilgisayariniz her acildiginda otomatik olarak sessizce calisacaktir.
echo  * Bu islemi yalnizca 1 defa yapmaniz yeterlidir!
echo  * Artik web sayfasina donup "Belgeyi Oku & Tara" butonuna basabilirsiniz.
echo ================================================================
timeout /t 5 >nul
