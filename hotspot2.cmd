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
echo   [ MANUAL BYPASS + CHECKER ]
echo   2. Apply TTL 129 (Desktop-heavy plans)
echo   3. Apply TTL 65  (Mobile-heavy plans)
echo.
echo   [ UTILITIES ]
echo   4. Reset to Windows Default (TTL 128)
echo   5. AUTO-SCANNER (Find working TTL automatically)
echo.
echo ========================================================
set /p choice=Select an option (1-5): 

if '%choice%'=='1' goto checkSettings
:: Now calls :applyAndTest instead of just :applyTTL
if '%choice%'=='2' call :applyAndTest 129 & pause & goto mainMenu
if '%choice%'=='3' call :applyAndTest 65 & pause & goto mainMenu
if '%choice%'=='4' call :resetDefault & pause & goto mainMenu
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
:: FUNCTION: Apply Manual TTL & Verify (The "Checker")
:: ----------------------------------------------------------
:applyAndTest
set val=%1
echo.
echo --------------------------------------------------------
echo [ACTION] Applying TTL %val%...
netsh int ipv4 set global defaultcurhoplimit=%val% >nul
netsh int ipv6 set global defaultcurhoplimit=%val% >nul

:: Step 1: System Verification
:: We ping localhost to see what the OS uses for its own packets
for /f "tokens=6" %%a in ('ping -n 1 127.0.0.1 ^| find "TTL="') do set "sysTTL=%%a"
set "sysTTL=!sysTTL:TTL=!"

if "!sysTTL!"=="%val%" (
    echo    [OK] System configuration updated successfully.
) else (
    echo    [ERROR] System stuck on TTL !sysTTL!. Admin rights might be blocked.
    exit /b
)

:: Step 2: Internet Connectivity Test
echo [TEST] Checking Internet Connection...
ping -n 1 -w 1500 8.8.8.8 | find "TTL=" >nul
if %errorlevel%==0 (
    echo    [SUCCESS] Internet is REACHABLE with TTL %val%.
    echo    Bypass should be active.
) else (
    echo    [WARNING] Internet unreachable! 
    echo    This TTL value (%val%) is likely blocked by your telco.
    echo    Try the other manual option or use the Auto-Scanner.
)
echo --------------------------------------------------------
exit /b

:: ----------------------------------------------------------
:: FUNCTION: Reset
:: ----------------------------------------------------------
:resetDefault
echo.
echo Resetting to Windows Default (128)...
netsh int ipv4 set global defaultcurhoplimit=128 >nul
netsh int ipv6 set global defaultcurhoplimit=128 >nul
echo Done.
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
netsh int ipv4 set global defaultcurhoplimit=%testVal% >nul
netsh int ipv6 set global defaultcurhoplimit=%testVal% >nul

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
