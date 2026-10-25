@echo off
setlocal

if "%~1"=="" (
    echo Usage: %~nx0 ^<script_name^> [args...]
    echo Example: %~nx0 01_setup_env.sh
    echo          %~nx0 02_sync_source.sh
    echo          %~nx0 05_build.sh userdebug
    exit /b 1
)

set "SCRIPT_NAME=%~1"
set "ARGS="

shift
:parse_args
if "%~1"=="" goto done_args
set "ARGS=%ARGS% %1"
shift
goto parse_args
:done_args

:: Resolve project root directory dynamically
set "PROJECT_DIR="
if exist "%CD%\manifests\racer.xml" (
    set "PROJECT_DIR=%CD%"
) else if exist "%~dp0..\manifests\racer.xml" (
    for %%I in ("%~dp0..") do set "PROJECT_DIR=%%~fI"
) else if exist "%~dp0manifests\racer.xml" (
    set "PROJECT_DIR=%~dp0"
)

if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

set "FORWARD_DIR=%PROJECT_DIR:\=/%"
for /f "tokens=*" %%i in ('wsl -d Ubuntu wslpath -u "%FORWARD_DIR%"') do set "WSL_PROJECT_DIR=%%i"

echo [WSL Bridge] Project Directory: %WSL_PROJECT_DIR%
echo [WSL Bridge] Running: ./scripts/%SCRIPT_NAME%%ARGS%
wsl -d Ubuntu bash -c "cd '%WSL_PROJECT_DIR%' && bash './scripts/%SCRIPT_NAME%'%ARGS%"
