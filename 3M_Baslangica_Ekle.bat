@echo off
title 3M PV40/PV60 Otomatik Baslatma Kurulumu
echo ============================================================
echo   3M PV40 / PV60 (AT9000 MK2) Windows Baslangicina Ekleniyor
echo ============================================================
echo.

set EXE_PATH=C:\Program Files (x86)\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin\OutputWedgeSysTray.exe

if not exist "%EXE_PATH%" (
    echo [HATA] 3M OutputWedge uygulamasi bulunamadi:
    echo "%EXE_PATH%"
    echo Lutfen SDK kurulumunu kontrol ediniz.
    pause
    exit /b
)

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "3M_DocumentReader" /t REG_SZ /d "\"%EXE_PATH%\"" /f >nul
if "%ERRORLEVEL%"=="0" (
    echo [BASARILI] 3M Okuyucu servisi Windows baslangicina eklendi!
    echo Bilgisayar her acildiginda veya kullanici giris yaptiginda servis arka planda otomatik calisacaktir.
    echo Kullanicilarin veya polis memurlarinin artik hicbir dosya calistirmasina gerek YOKTUR.
) else (
    echo [UYARI] Kayit defterine eklenirken bir sorun olustu.
)

echo.
echo Servis simdi baslatiliyor...
tasklist /FI "IMAGENAME eq OutputWedgeSysTray.exe" 2>NUL | find /I /N "OutputWedgeSysTray.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [BILGI] 3M OutputWedge servisi su anda zaten aktif ve calisiyor.
) else (
    start "" "%EXE_PATH%"
    echo [BASARILI] Servis baslatildi ve sistem tepsisine yerlesti.
)

echo.
echo Islem tamamlandi.
timeout /t 5
