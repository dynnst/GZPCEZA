@echo off
title 3M PV40/PV60 Otomatik Baslatmayi Kaldir
echo ============================================================
echo   3M Okuyucu Windows Baslangicindan Kaldiriliyor...
echo ============================================================
echo.

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "3M_DocumentReader" /f >nul 2>&1
if "%ERRORLEVEL%"=="0" (
    echo [BASARILI] 3M Okuyucu servisi Windows baslangicindan cikarildi.
) else (
    echo [BILGI] Baslangicta kayitli 3M servisi bulunamadi.
)

echo.
timeout /t 3
