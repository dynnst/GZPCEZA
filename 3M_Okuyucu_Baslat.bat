@echo off
title 3M PV40 / PV60 Optik Okuyucu Servisi
echo ============================================================
echo   3M PV40 / PV60 (AT9000 MK2) Optik Okuyucu Servisi Baslatiliyor...
echo ============================================================

tasklist /FI "IMAGENAME eq OutputWedgeSysTray.exe" 2>NUL | find /I /N "OutputWedgeSysTray.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [BILGI] 3M OutputWedge servisi zaten calisiyor.
) else (
    if exist "C:\Program Files (x86)\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin\OutputWedgeSysTray.exe" (
        start "" "C:\Program Files (x86)\Thales\Gemalto Document Reader SDK\3.7.1.18\Bin\OutputWedgeSysTray.exe"
        echo [BASARILI] 3M OutputWedge servisi baslatildi. Sistem tepsisinde calismaktadir.
    ) else (
        echo [UYARI] OutputWedgeSysTray.exe bulunamadi! Lutfen SDK kurulumunu kontrol ediniz.
    )
)

echo.
echo Cihaz Durumu: Pasaportu okuyucu camina koydugunuzda otomatik okuma yapilacaktir.
echo E-INAD ekraninda pasaport aninda taninip bilgiler forma otomatik doldurulacaktir.
echo.
timeout /t 3 >nul
