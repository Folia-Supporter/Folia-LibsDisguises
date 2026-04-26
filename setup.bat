@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion

for /f "tokens=2 delims==" %%a in ('findstr /b "upstreamUrl=" gradle.properties') do set UPSTREAM_URL=%%a
for /f "tokens=2 delims==" %%a in ('findstr /b "upstreamRef=" gradle.properties') do set UPSTREAM_REF=%%a

if "%UPSTREAM_URL%"=="" (
    echo ERROR: upstreamUrl not found in gradle.properties
    goto end
)
if "%UPSTREAM_REF%"=="" (
    echo ERROR: upstreamRef not found in gradle.properties
    goto end
)

if not exist src\.git (
    echo Cloning upstream (%UPSTREAM_URL%)...
    git -c core.autocrlf=false clone %UPSTREAM_URL% src
    git -C src config core.autocrlf false
) else (
    echo src\ already exists, fetching latest...
    git -C src fetch origin
)

echo Checking out upstream ref: %UPSTREAM_REF%
git -C src checkout -f %UPSTREAM_REF%

git -C src am --abort 2>nul

set PATCH_COUNT=0
for %%f in (patches\*.patch) do set /a PATCH_COUNT+=1

if %PATCH_COUNT%==0 (
    echo No patches found in patches\ — setup complete (clean upstream).
    goto end
)

echo Applying patches...
for %%f in (patches\*.patch) do (
    echo   -^> %%f
    git -C src am --ignore-whitespace "..\%%f"
    if errorlevel 1 (
        echo.
        echo CONFLICT: Failed to apply %%f
        echo Go into src\, resolve conflicts, then run:
        echo   git -C src add -A ^&^& git -C src am --continue
        goto end
    )
)

echo.
echo Done! Source is ready in src\
echo To build: cd src ^&^& gradlew build

:end
endlocal
pause
