@echo off
:: System Diagnostic and Repair Script
:: Must be run as Administrator

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script requires Administrator privileges!
    echo Right-click the file and select "Run as administrator"
    pause
    exit /b 1
)

echo ========================================
echo   SYSTEM DIAGNOSTIC AND REPAIR TOOL
echo ========================================
echo.
echo Starting system diagnostics...
echo This process may take 30-60 minutes depending on your system.
echo.

:: Create log file with timestamp
set "logfile=%USERPROFILE%\Desktop\SystemRepair_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log"
set "logfile=%logfile: =0%"

echo Log file: %logfile%
echo System Repair Log - %date% %time% > "%logfile%"
echo ================================================ >> "%logfile%"
echo. >> "%logfile%"

:: ========================================
:: STEP 1: System File Checker (SFC)
:: ========================================
echo.
echo Running System File Checker (SFC)...
echo This scans and repairs corrupt Windows system files.
echo System File Checker >> "%logfile%"
echo Started: %time% >> "%logfile%"

sfc /scannow >> "%logfile%" 2>&1

if %errorLevel% equ 0 (
    echo SFC scan completed successfully.
    echo Result: SUCCESS >> "%logfile%"
) else (
    echo SFC scan completed with warnings or errors.
    echo Result: WARNING - Check log for details >> "%logfile%"
)
echo Finished: %time% >> "%logfile%"
echo. >> "%logfile%"

:: ========================================
:: STEP 2: DISM - Check Health
:: ========================================
echo.
echo Checking Windows Image Health (DISM)...
echo This verifies the integrity of Windows component store.
echo DISM Check Health >> "%logfile%"
echo Started: %time% >> "%logfile%"

DISM /Online /Cleanup-Image /CheckHealth >> "%logfile%" 2>&1

echo Finished: %time% >> "%logfile%"
echo. >> "%logfile%"

:: ========================================
:: STEP 3: DISM - Scan Health
:: ========================================
echo.
echo Scanning Windows Image Health (DISM)...
echo This performs a deeper scan of the component store.
echo DISM Scan Health >> "%logfile%"
echo Started: %time% >> "%logfile%"

DISM /Online /Cleanup-Image /ScanHealth >> "%logfile%" 2>&1

echo Finished: %time% >> "%logfile%"
echo. >> "%logfile%"

:: ========================================
:: STEP 4: DISM - Restore Health
:: ========================================
echo.
echo Repairing Windows Image (DISM)...
echo This repairs any corruption found in the component store.
echo DISM Restore Health >> "%logfile%"
echo Started: %time% >> "%logfile%"

DISM /Online /Cleanup-Image /RestoreHealth >> "%logfile%" 2>&1

if %errorLevel% equ 0 (
    echo DISM repair completed successfully.
    echo Result: SUCCESS >> "%logfile%"
) else (
    echo DISM repair completed with warnings.
    echo Result: WARNING - Check log for details >> "%logfile%"
)
echo Finished: %time% >> "%logfile%"
echo. >> "%logfile%"

:: ========================================
:: STEP 5: Check Disk (Schedule on next reboot)
:: ========================================
echo.
echo Scheduling Disk Check (CHKDSK)...
echo This will check and repair disk errors on next reboot.
echo Check Disk >> "%logfile%"
echo Started: %time% >> "%logfile%"

echo Y | chkdsk C: /F /R /X >> "%logfile%" 2>&1

echo Disk check scheduled for next reboot >> "%logfile%"
echo Finished: %time% >> "%logfile%"
echo. >> "%logfile%"

:: ========================================
:: STEP 6: Windows Defender Quick Scan
:: ========================================
echo.
echo Running Windows Defender Quick Scan...
echo This performs a quick malware scan of common infection points.
echo Windows Defender Scan >> "%logfile%"
echo Started: %time% >> "%logfile%"

"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -Scan -ScanType 1 >> "%logfile%" 2>&1

if %errorLevel% equ 0 (
    echo Defender scan completed - No threats detected.
    echo Result: CLEAN >> "%logfile%"
) else (
    echo Defender scan found potential threats or warnings.
    echo Result: THREATS DETECTED - Check Windows Security >> "%logfile%"
)
echo Finished: %time% >> "%logfile%"
echo. >> "%logfile%"

:: ========================================
:: STEP 7: Update Defender Signatures
:: ========================================
echo.
echo Updating Windows Defender Signatures...
echo This ensures you have the latest virus definitions.
echo Defender Update >> "%logfile%"
echo Started: %time% >> "%logfile%"

"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate >> "%logfile%" 2>&1

if %errorLevel% equ 0 (
    echo Defender signatures updated successfully.
    echo Result: SUCCESS >> "%logfile%"
) else (
    echo Defender signature update encountered issues.
    echo Result: WARNING >> "%logfile%"
)
echo Finished: %time% >> "%logfile%"
echo. >> "%logfile%"

:: ========================================
:: COMPLETION SUMMARY
:: ========================================
echo.
echo ========================================
echo  DIAGNOSTICS COMPLETE
echo ========================================
echo.
echo All diagnostic and repair tasks completed!
echo.
echo IMPORTANT NOTES:
echo A full disk check (CHKDSK) has been scheduled
echo    and will run on your next system reboot.
echo.
echo  Review the detailed log file at:
echo    %logfile%
echo.
echo Check Windows Security for any threats found.
echo.
echo If issues persist, you may need to:
echo    - Run SFC again after the disk check completes
echo    - Perform a Windows Repair Install
echo    - Check hardware health (RAM, HDD/SSD)
echo.
echo ================================================ >> "%logfile%"
echo Diagnostics completed: %date% %time% >> "%logfile%"
echo ================================================ >> "%logfile%"

echo.
echo Press any key to open the log file...
pause >nul
start "" "%logfile%"

echo.
echo Do you want to restart now to run the disk check? (Y/N)
set /p restart="Enter your choice: "
if /i "%restart%"=="Y" (
    echo Restarting system in 10 seconds...
    shutdown /r /t 10 /c "Restarting to complete disk check"
) else (
    echo Remember to restart later to complete the disk check.
)

pause