@echo off
setlocal enabledelayedexpansion
title Ultimate Hotspot Bypass & Auto-Scanner

:: ========================================================
:: [CORE] ADMIN PRIVILEGES CHECK
:: ========================================================
if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)

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

:: ========================================================
:: [CORE] MAIN MENU
:: ========================================================
:mainMenu
cls
echo ========================================================
echo               ULTIMATE HOTSPOT BYPASS TOOL
echo ========================================================
echo.
echo   [ STATUS CHECK ]
echo   1. View Current Global Network Settings
echo.
echo   [ MANUAL BYPASS + DATA VERIFICATION ]
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
if '%choice%'=='2' call :applyAndTest 129 & pause & goto mainMenu
if '%choice%'=='3' call :applyAndTest 65 & pause & goto mainMenu
if '%choice%'=='4' call :resetDefault & pause & goto mainMenu
if '%choice%'=='5' goto autoScanner
echo Invalid option. & pause & goto mainMenu

:: ========================================================
:: FUNCTION: View Settings
:: ========================================================
:checkSettings
echo.
echo Current Global IPv4 Configuration:
netsh int ipv4 show global | findstr "Default Hop Limit"
echo.
echo Current Global IPv6 Configuration:
netsh int ipv6 show global | findstr "Default Hop Limit"
pause
goto mainMenu

:: ========================================================
:: FUNCTION: Apply Manual TTL & Verify
:: ========================================================
:applyAndTest
set val=%1
echo.
echo --------------------------------------------------------
echo [ACTION] Applying TTL %val%...
netsh int ipv4 set global defaultcurhoplimit=%val% >nul
netsh int ipv6 set global defaultcurhoplimit=%val% >nul

:: Step 1: System Verification
for /f "tokens=6" %%a in ('ping -n 1 127.0.0.1 ^| find "TTL="') do set "sysTTL=%%a"
set "sysTTL=!sysTTL:TTL=!"
set "sysTTL=!sysTTL:=!"

if "!sysTTL!"=="%val%" (
    echo    [OK] System configuration updated successfully.
) else (
    echo    [ERROR] System reported TTL !sysTTL! (Expected: %val%).
    echo            Admin rights might be blocked or a reboot is needed.
    exit /b
)

:: Step 2: Connection & Data Verification
echo [TEST] Checking Connectivity...
ping -n 1 -w 1500 8.8.8.8 | find "TTL=" >nul
if %errorlevel%==0 (
    echo    [PING] Success. Verifying actual data throughput...
    call :verifyDownload
) else (
    echo    [FAIL] Ping blocked. Internet unreachable with TTL %val%.
)
echo --------------------------------------------------------
exit /b

:: ========================================================
:: FUNCTION: Download Simulation (The Real Test)
:: ========================================================
:verifyDownload
set "testUrl=https://link.testfile.org/15MB"
set "downFile=%temp%\ttl_test_file.tmp"

:: Attempt download with 15s timeout
:: -L follows redirects, -o saves file, --max-time limits hang
echo    [DATA] Simulating Download (15MB Test File)...
curl -L -o "%downFile%" "%testUrl%" --max-time 15 --insecure >nul 2>&1
set downStatus=%errorlevel%

:: Verify file existence and size > 0
if exist "%downFile%" (
    for %%A in ("%downFile%") do if %%~zA GTR 0 (
        set downStatus=0
    ) else (
        set downStatus=1
    )
    :: CLEANUP: Always delete the test file
    del "%downFile%" >nul 2>&1
) else (
    set downStatus=1
)

if %downStatus%==0 (
    echo    [SUCCESS] Download verified! Network is fully working.
    exit /b 0
) else (
    echo    [FAIL] Download incomplete or blocked. Carrier may be throttling.
    exit /b 1
)

:: ========================================================
:: FUNCTION: Reset to Default
:: ========================================================
:resetDefault
echo.
echo Resetting to Windows Default (128)...
netsh int ipv4 set global defaultcurhoplimit=128 >nul
netsh int ipv6 set global defaultcurhoplimit=128 >nul
echo Done.
exit /b

:: ========================================================
:: FUNCTION: Auto-Scanner
:: ========================================================
:autoScanner
cls
echo ========================================================
echo             STARTING AUTOMATIC TTL SCAN
echo ========================================================
echo This will cycle through common values.
echo 1. It PINGS to check basic connection.
echo 2. If Ping works, it DOWNLOADS to verify data.
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
pause
goto mainMenu

:: Helper function for Scanner
:testConnectivity
set testVal=%1
netsh int ipv4 set global defaultcurhoplimit=%testVal% >nul
netsh int ipv6 set global defaultcurhoplimit=%testVal% >nul

:: Quick Ping Filter (saves time on dead values)
ping -n 1 -w 800 8.8.8.8 | find "TTL=" >nul
if %errorlevel% NEQ 0 (
    echo    Testing TTL %testVal%... [No Ping]
    exit /b 1
)

:: If Ping works, Verify Data
echo    Testing TTL %testVal%... [Ping OK] -> Verifying Download...
call :verifyDownload
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
echo Both PING and DOWNLOAD verification passed.
echo.
echo 1. Keep this setting
echo 2. Continue scanning
set /p successChoice=Choose: 
if '%successChoice%'=='1' goto mainMenu
exit /b 1
