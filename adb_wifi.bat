@echo off
title ADB WIFI PRO CONNECT (SAFE MODE)
color 0A

echo ================================
echo   ADB WIFI PRO CONNECT
echo ================================
echo.

echo [1] Verification device USB...
adb devices

echo.
echo [2] Activation TCP/IP...
adb tcpip 5555

timeout /t 2 >nul

echo.
echo [3] Tentative detection IP...

set PHONE_IP=

for /f "tokens=3" %%a in ('adb shell ip route 2^>nul ^| findstr default') do (
    set GATEWAY=%%a
)

:: CORRECTION APPORTÉE ICI (suppression de delims=:)
for /f "tokens=2" %%a in ('adb shell ip -f inet addr show wlan0 2^>nul ^| findstr inet') do (
    set PHONE_IP=%%a
)

:: Nettoyage de l'IP (enlève le /24 à la fin)
for /f "tokens=1 delims=/" %%a in ("%PHONE_IP%") do (
    set PHONE_IP=%%a
)

echo.
if "%PHONE_IP%"=="" (
    echo [!] IP introuvable automatiquement
    echo.
    echo SOLUTION:
    echo 1. Active "Debogage sans fil" sur ton telephone
    echo 2. As-tu bien connecte le telephone au meme reseau WiFi que le PC ?
    echo 3. Utilise manuellement : adb connect IP_DU_TELEPHONE:5555
    echo.
    goto END
)

echo IP detectee : %PHONE_IP%

echo.
echo [4] Connexion WiFi...
adb connect %PHONE_IP%:5555

echo.
echo [5] Verification...
adb devices

echo.
echo ================================
echo   TERMINÉ
echo ================================

:END
pause