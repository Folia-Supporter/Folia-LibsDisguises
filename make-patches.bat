@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion

for /f "tokens=2 delims==" %%a in ('findstr /b "upstreamRef=" gradle.properties') do set UPSTREAM_REF=%%a

if "%UPSTREAM_REF%"=="" (
    echo ERROR: upstreamRef not found in gradle.properties
    goto end
)

if not exist src\.git (
    echo ERROR: src\ not found. Run setup.bat first.
    goto end
)

for /f %%a in ('git -C src rev-list --count %UPSTREAM_REF%..HEAD') do set COMMIT_COUNT=%%a

if "%COMMIT_COUNT%"=="0" (
    echo No commits ahead of upstreamRef ^(%UPSTREAM_REF%^) in src\
    echo Nothing to do.
    goto end
)

echo Rebuilding patches from %COMMIT_COUNT% commit(s) in src\ since %UPSTREAM_REF%...

if exist patches\ rmdir /s /q patches\
mkdir patches

git -C src format-patch %UPSTREAM_REF%..HEAD --output-directory "..\patches"

echo.
echo Generated patches:
for %%f in (patches\*.patch) do echo   %%f
echo.
echo Done! Run 'git add patches\' to stage updated patches.

:end
endlocal
pause
