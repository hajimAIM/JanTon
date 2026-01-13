@echo off
setlocal enabledelayedexpansion
title Ultimate Hotspot Bypass & Auto-Scanner
:: [CORE] Centralized Admin Check
if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)

:: [CORE] Ensure Admin Access for Registry/Netsh
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )

:mainMenu
cls
echo ========================================================
echo              ULTIMATE HOTSPOT BYPASS TOOL
echo ========================================================
echo.
echo   [ STATUS CHECK ]
echo   1. View Current Global Network Settings
echo.
echo   [ MANUAL BYPASS ]
echo   2. Apply TTL 129 (Common for Desktop-heavy plans)
echo   3. Apply TTL 65  (Common for Mobile-heavy plans)
echo.
echo   [ UTILITIES ]
echo   4. Reset to Windows Default (TTL 128)
echo   5. AUTO-SCANNER (Detects working TTL automatically)
echo.
echo ========================================================
set /p choice=Select an option (1-5): 

if '%choice%'=='1' goto checkSettings
if '%choice%'=='2' call :applyTTL 129 & pause & goto mainMenu
if '%choice%'=='3' call :applyTTL 65 & pause & goto mainMenu
if '%choice%'=='4' call :applyTTL 128 & echo Reset Complete. & pause & goto mainMenu
if '%choice%'=='5' goto autoScanner
echo Invalid option. & pause & goto mainMenu

:: ----------------------------------------------------------
:: FUNCTION: View Settings
:: ----------------------------------------------------------
:checkSettings
echo.
echo Current Global IPv4 Configuration:
netsh int ipv4 show global | findstr "Default Hop Limit"
echo.
echo Current Global IPv6 Configuration:
netsh int ipv6 show global | findstr "Default Hop Limit"
pause
goto mainMenu

:: ----------------------------------------------------------
:: FUNCTION: Apply TTL
:: ----------------------------------------------------------
:applyTTL
set val=%1
echo.
echo [!] Setting Global Hop Limit to %val%...
netsh int ipv4 set global defaultcurhoplimit=%val% >nul
netsh int ipv6 set global defaultcurhoplimit=%val% >nul
exit /b

:: ----------------------------------------------------------
:: FUNCTION: Auto-Scanner
:: ----------------------------------------------------------
:autoScanner
cls
echo ========================================================
echo             STARTING AUTOMATIC TTL SCAN
echo ========================================================
echo This will test common values and ranges for connectivity.
echo Press Ctrl+C to stop at any time.
echo.

:: 1. Priority Checks
echo [PHASE 1] Testing Priority Values (65, 129)...
call :testConnectivity 65
if !errorlevel!==0 goto foundSuccess
call :testConnectivity 129
if !errorlevel!==0 goto foundSuccess

:: 2. Range 60-70
echo.
echo [PHASE 2] Scanning Range 60-70...
for /L %%G in (60,1,70) do (
    call :testConnectivity %%G
    if !errorlevel!==0 goto foundSuccess
)

:: 3. Range 110-130
echo.
echo [PHASE 3] Scanning Range 110-130...
for /L %%G in (110,1,130) do (
    call :testConnectivity %%G
    if !errorlevel!==0 goto foundSuccess
)

echo.
echo [FAIL] Scanned all ranges. No working TTL found.
echo Your carrier may be using Deep Packet Inspection (DPI).
pause
goto mainMenu

:testConnectivity
set testVal=%1
:: Apply
netsh int ipv4 set global defaultcurhoplimit=%testVal% >nul
netsh int ipv6 set global defaultcurhoplimit=%testVal% >nul

:: Verify Local Apply (Optional safety check)
ping -n 1 127.0.0.1 | find "TTL=%testVal%" >nul
if errorlevel 1 (
    echo    [!] Error: Windows failed to apply TTL %testVal%.
    exit /b 1
)

:: Test Internet
echo    Testing TTL %testVal%...
ping -n 1 -w 800 8.8.8.8 | find "TTL=" >nul
if %errorlevel%==0 (
    exit /b 0
) else (
    exit /b 1
)

:foundSuccess
echo.
echo ========================================================
echo [SUCCESS] Working TTL Found: %testVal%
echo ========================================================
echo Internet is reachable with this setting.
echo.
echo 1. Keep this setting
echo 2. Continue scanning
set /p successChoice=Choose: 
if '%successChoice%'=='1' goto mainMenu
exit /b 1
