@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion

for /f "tokens=2 delims==" %%a in ('findstr /b "upstreamRef=" gradle.properties') do set OLD_REF=%%a

if "%OLD_REF%"=="" (
    echo ERROR: upstreamRef not found in gradle.properties
    goto end
)

if not exist src\.git (
    echo ERROR: src\ not found. Run setup.bat first.
    goto end
)

echo Fetching upstream...
git -C src fetch origin

for /f %%a in ('git -C src rev-parse origin/master') do set NEW_REF=%%a

if "%OLD_REF%"=="%NEW_REF%" (
    echo Already up to date ^(upstream is still %OLD_REF:~0,12%^)
    goto end
)

echo Rebasing our commits onto new upstream...
echo   old: %OLD_REF:~0,12%
echo   new: %NEW_REF:~0,12%
echo.

git -C src rebase --onto %NEW_REF% %OLD_REF%
if errorlevel 1 (
    echo.
    echo CONFLICT during rebase. Go into src\, resolve conflicts, then run:
    echo   git -C src add -A ^&^& git -C src rebase --continue
    echo.
    echo After rebase is fully done, run these commands manually:
    echo   1. sed or powershell to update upstreamRef in gradle.properties
    echo   2. make-patches.bat
    echo   3. git add gradle.properties patches\
    echo   4. git commit -m "Update upstream to %NEW_REF:~0,12%"
    goto end
)

powershell -Command "(Get-Content gradle.properties) -replace '^upstreamRef=.*', 'upstreamRef=%NEW_REF%' | Set-Content gradle.properties"

call make-patches.bat

git add gradle.properties patches\
git commit -m "Update upstream to %NEW_REF:~0,12%"

echo.
echo Done! Updated upstream from %OLD_REF:~0,12% to %NEW_REF:~0,12%

:end
endlocal
pause
