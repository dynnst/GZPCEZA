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
set SHORTCUT_VBS=%STARTUP_DIR%\EgmReaderBridge.vbs

echo [1/3] Mevcut kopru ve eski servisler temizleniyor...
taskkill /F /IM EgmReaderBridge.exe >nul 2>&1
taskkill /F /IM OutputWedgeSysTray.exe >nul 2>&1
taskkill /F /IM OutputWedge.exe >nul 2>&1
timeout /t 1 >nul

echo [2/3] Kopru dosyalari yerel sisteme yukleniyor (Yonetici yetkisi gerekmez)...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
copy /Y "%SCRIPT_DIR%EgmReaderBridge.exe" "%TARGET_DIR%\" >nul

(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo WshShell.Run """%TARGET_DIR%\EgmReaderBridge.exe""", 0, False
) > "%TARGET_DIR%\Kopru_Arka_Planda_Baslat.vbs"

(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo WshShell.Run """%TARGET_DIR%\Kopru_Arka_Planda_Baslat.vbs""", 0, False
) > "%SHORTCUT_VBS%"

reg add "HKCU\Software\Classes\egm-reader" /ve /d "URL:EgmReaderBridge Protocol" /f >nul 2>&1
reg add "HKCU\Software\Classes\egm-reader" /v "URL Protocol" /d "" /f >nul 2>&1
reg add "HKCU\Software\Classes\egm-reader\shell\open\command" /ve /d "wscript.exe \"%TARGET_DIR%\Kopru_Arka_Planda_Baslat.vbs\"" /f >nul 2>&1

echo [3/3] Optik okuyucu koprusu arka planda baslatiliyor...
wscript.exe "%TARGET_DIR%\Kopru_Arka_Planda_Baslat.vbs"

echo.
echo ================================================================
echo  [BASARILI] Optik okuyucu koprusu kuruldu ve calismaya basladi!
echo.
echo  * Bilgisayariniz her acildiginda otomatik olarak sessizce calisacaktir.
echo  * Bu islemi yalnizca 1 defa yapmaniz yeterlidir.
echo  * Artik web sayfasina donup "Optik Okuyucuya Baglan" ve
echo    "Belgeyi Oku & Tara" butonlarini kullanabilirsiniz.
echo ================================================================
echo.
echo Bu pencereyi kapatabilirsiniz...
timeout /t 5
